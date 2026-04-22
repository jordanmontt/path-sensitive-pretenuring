#!/usr/bin/env bash
set -euo pipefail


BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

declare -A BENCHMARK_CLASSES=(
    ["cormas"]="VeritasCormas"
    ["microdown"]="VeritasMicrodown"
    ["dataframe"]="VeritasDataFrame"
    ["moose"]="VeritasMoose"
)

STRATEGIES=("applicationMethod" "callerOfNew" "locationOfNew")

log() { echo; echo "▸ $*"; echo; }

setup_base_image() {
    mkdir -p "$BASE_DIR"
    cd "$BASE_DIR"
    wget --quiet -O - get.pharo.org/130+vm | bash
    cd - > /dev/null
    log "Baseimage downloaded"
}

create_image() {
    local image_name="$1"
    local dir_name="${2:-$image_name}"

    mkdir -p "$dir_name"
    "$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save "../$dir_name/$image_name"
    cp "$BASE_DIR"/*.sources "./$dir_name/"
    log "Created image: $dir_name"
}

install_veritas() {
    local image_path="$1"
    local veritas_bench="$2"

    "$PHARO_CMD" --headless "$image_path" metacello install "github://jordanmontt/PharoVeritasBenchSuite:main" "$veritas_bench"
    log "Installed Veritas $veritas_bench for $image_path"
}

install_path_sensitive_pretenuring() {
    local image_path="$1"
    local baseline_group="$2"

    "$PHARO_CMD" --headless "$image_path" metacello install "github://jordanmontt/path-sensitive-pretenuring:main" "PathSensitivePretenuring" "--groups=$baseline_group"
    log "Installed Path Sensitive Pretenuring for baseline group $baseline_group for $image_path"
}

download_spec2_book() {
    local target_dir="$1"

    local TMP_CLONE_DIR
    TMP_CLONE_DIR=$(mktemp -d)
    git clone --quiet --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
    mv "$TMP_CLONE_DIR" "./$target_dir/Spec2Book"
    log "Spec2Book downloaded for $target_dir"
}

move_dataset() {
    local target_dir="$1"
    local file_name="$2"

    mv "./$target_dir/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/$file_name" "./$target_dir/"
    log "$file_name moved to $target_dir"
}

install_base_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"

        create_image "$benchmark"
        install_veritas "./$benchmark/$benchmark.image" "$veritas_bench"
    done
}

install_strategy_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        for strategy in "${STRATEGIES[@]}"; do
            local name="$benchmark-$strategy"
            local image_path="./$name/$name.image"

            create_image "$name"

            case "$benchmark" in
                cormas)
                    install_path_sensitive_pretenuring "$image_path" "cormas-$strategy"
                    ;;
                microdown)
                    download_spec2_book "$name"
                    install_path_sensitive_pretenuring "$image_path" "microdown-$strategy"
                    ;;
                dataframe)
                    install_path_sensitive_pretenuring "$image_path" "dataFrame-$strategy"
                    move_dataset "$name" "tiny_dataset.csv"
                    ;;
                moose)
                    install_path_sensitive_pretenuring "$image_path" "moose-$strategy"
                    move_dataset "$name" "sbscl.json"
                    ;;
            esac

        done
    done
}

main() {
    setup_base_image

    install_base_images
    install_strategy_images

    log "Successfully finished!"
}

main "$@"
