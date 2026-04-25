#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

declare -A BENCHMARK_CLASSES=(
    ["cormas"]="VeritasCormas"
    ["honeyGinger"]="VeritasHoneyGinger"
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

    local source_dir="$(dirname "$source_image")"
    local source_basename="$(basename "$source_image" .image)"

    cp -r "$source_dir" "./$dir_name"

    mv "./$dir_name/$source_basename.image"   "./$dir_name/$image_name.image"
    mv "./$dir_name/$source_basename.changes" "./$dir_name/$image_name.changes"

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

move_dataset() {
    local target_dir="$1"
    local file_name="$2"
    mv "./$target_dir/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/$file_name" "./$target_dir/"
    log "$file_name moved to $target_dir"
}

install_pretenured_methods() {
    local image_path="$1"
    local benchmark="$2"
    local strategy="$3"
    local json_file="$benchmark-$strategy.json"
    "$PHARO_CMD" --headless "$image_path" eval --save "| file | file := (FileLocator localDirectory / 'iceberg' / 'jordanmontt' / 'path-sensitive-pretenuring' / 'pretenuredMethods' / '$json_file') asFileReference. PathSensitvePretenuringExperiment new deserializeAndInstallCompiledMethodsIn: file"
    log "Installed pretenured methods ($json_file) for $image_path"
}

install_baseline_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"
        local image_path="./$benchmark/$benchmark.image"

        create_image "$BASE_IMAGE_FILE" "$benchmark"
        install_path_sensitive_pretenuring "$image_path"
        install_veritas "$image_path" "$veritas_bench"

        case "$benchmark" in
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
            local image_path="./$name/$name.image"
            create_image "$baseline_image" "$name"

            case "$benchmark" in
                dataframe)
                    cp "./$benchmark/tiny_dataset.csv" "./$name/"
                    log "tiny_dataset.csv copied to $name"
                    ;;
                moose)
                    cp "./$benchmark/sbscl.json" "./$name/"
                    log "sbscl.json copied to $name"
                    ;;
            esac

            install_pretenured_methods "$image_path" "$benchmark" "$strategy"
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