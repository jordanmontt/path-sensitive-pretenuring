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
    local source_image="$1"
    local image_name="$2"
    local dir_name="${3:-$image_name}"
    mkdir -p "$dir_name"
    # The 'save' path is relative to the source image's directory.
    # Since both baseimage/ and benchmark/ dirs are one level deep,
    # "../$dir_name/$image_name" always resolves correctly.
    "$PHARO_CMD" --headless "$source_image" save "../$dir_name/$image_name"
    cp "$BASE_DIR"/*.sources "./$dir_name/"
    log "Created image: $dir_name/$image_name (from $source_image)"
}

install_veritas() {
    local image_path="$1"
    local veritas_bench="$2"
    # This only works for Pharo 13 since the metacello command line interface changed
    "$PHARO_CMD" --headless "$image_path" metacello install "github://jordanmontt/PharoVeritasBenchSuite:main" "BaselineOf$veritas_bench"
    log "Installed Veritas $veritas_bench for $image_path"
}

install_path_sensitive_pretenuring() {
    local image_path="$1"
    "$PHARO_CMD" --headless "$image_path" metacello install \
        "github://jordanmontt/path-sensitive-pretenuring:main" \
        "BaselineOfPathSensitivePretenuring"
    log "Installed Path Sensitive Pretenuring for $image_path"
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

install_baseline_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"
        local image_path="./$benchmark/$benchmark.image"

        create_image "$BASE_IMAGE_FILE" "$benchmark"
        install_path_sensitive_pretenuring "$image_path"
        install_veritas "$image_path" "$veritas_bench"

        case "$benchmark" in
            microdown)
                download_spec2_book "$benchmark"
                ;;
            dataframe)
                move_dataset "$benchmark" "tiny_dataset.csv"
                ;;
            moose)
                move_dataset "$benchmark" "sbscl.json"
                ;;
        esac
    done
}

install_strategy_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local baseline_image="./$benchmark/$benchmark.image"

        for strategy in "${STRATEGIES[@]}"; do
            local name="$benchmark-$strategy"
            create_image "$baseline_image" "$name"

            case "$benchmark" in
                microdown)
                    cp -r "./$benchmark/Spec2Book" "./$name/Spec2Book"
                    log "Spec2Book copied to $name"
                    ;;
                dataframe)
                    cp "./$benchmark/tiny_dataset.csv" "./$name/"
                    log "tiny_dataset.csv copied to $name"
                    ;;
                moose)
                    cp "./$benchmark/sbscl.json" "./$name/"
                    log "sbscl.json copied to $name"
                    ;;
            esac
        done
    done
}

main() {
    setup_base_image
    install_baseline_images
    install_strategy_images
    log "Successfully finished!"
}

main "$@"