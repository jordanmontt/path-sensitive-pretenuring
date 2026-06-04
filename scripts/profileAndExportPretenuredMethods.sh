#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

declare -A BENCHMARK_CLASSES=(
    ["cormas"]="VeritasCormas"
    ["dataframe"]="VeritasDataFrame"
    # ["moose"]="VeritasMoose"
)

SAMPLING_RATES=("1/1000" "1/100")

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

    local source_dir="$(dirname "$source_image")"
    local source_basename="$(basename "$source_image" .image)"

    cp -r "$source_dir" "./$image_name"
    mv "./$image_name/$source_basename.image"   "./$image_name/$image_name.image"
    mv "./$image_name/$source_basename.changes" "./$image_name/$image_name.changes"

    log "Created image: $image_name (from $source_image)"
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
    "$PHARO_CMD" --headless "$image_path" metacello install "github://jordanmontt/path-sensitive-pretenuring:main" "BaselineOfPathSensitivePretenuring"
    log "Installed Path Sensitive Pretenuring for $image_path"
}

copy_dataset() {
    local target_dir="$1"
    local file_name="$2"
    cp "$SCRIPT_DIR/$file_name" "./$target_dir/"
    log "$file_name copied to $target_dir"
}

profile_and_export_pretenured_methods() {
    local image_path="$1"
    local sampling_rate="$2"
    local veritas_bench="$3"

    log "Profiling and compiling the pretenured for $image_path with sampling rate $sampling_rate"
    "$PHARO_CMD" --headless "$image_path" eval \
        "PSPRunner new samplingRate: $sampling_rate; benchmarkClass: $veritas_bench; pretenurePathsForAllStrategies"
    log "Exported pretenured methods for $image_path with sampling rate $sampling_rate"
}

move_dataset_from_veritas_repo() {
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
            dataframe)
                copy_dataset "$benchmark" "tiny_fifty_times_larger_dataset.csv"
                ;;
            moose)
                move_dataset_from_veritas_repo "$benchmark" "sbscl.json"
                ;;
        esac
    done
}

install_strategy_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"
        local baseline_image="./$benchmark/$benchmark.image"

        for sampling_rate in "${SAMPLING_RATES[@]}"; do
            local safe_rate="${sampling_rate//\//_}"  # 1/1000 -> 1_1000
            local name="$benchmark-$safe_rate"
            local image_path="./$name/$name.image"
            create_image "$baseline_image" "$name"
            profile_and_export_pretenured_methods "$image_path" "$sampling_rate" "$veritas_bench"
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

