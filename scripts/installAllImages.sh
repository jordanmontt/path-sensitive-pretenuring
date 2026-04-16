BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

BENCHMARK_CLASSES=(
    ["cormas"]="VeritasCormas"
    ["microdown"]="VeritasMicrodown"
    ["dataframe"]="VeritasDataFrame"
    ["moose"]="VeritasMoose"
)

STRATEGIES=("applicationMethod" "callerOfNew" "locationOfNew")

setup_base_image() {
    mkdir -p baseimage
    cd baseimage || return 1
    wget --quiet -O - get.pharo.org/140+vm | bash
    cd - > /dev/null || return 1
    echo
    echo "Baseimage downloaded"
    echo; echo
}

create_image() {
    local image_name="$1"
    local dir_name="${2:-$image_name}"

    mkdir -p "$dir_name"
    "$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save "../$dir_name/$image_name"
    cp "$BASE_DIR"/*.sources "./$dir_name/"
    echo "Created image: $dir_name"
    echo; echo
}

install_veritas() {
    local image_path="$1"
    local veritas_bench="$2"

    "$PHARO_CMD" --headless "$image_path" metacello install --save "github://jordanmontt/PharoVeritasBenchSuite:main" "$veritas_bench"
    echo "Installed Veritas $veritas_bench for $image_path"
    echo; echo
}

install_path_sensitive_pretenuring() {
    local image_path="$1"

    "$PHARO_CMD" --headless "$image_path" metacello install --save "github://jordanmontt//path-sensitive-pretenuring:main" "PathSensitivePretenuring"
    echo "Installed Path Sensitive Pretenuring for $image_path"
    echo; echo
}

get_benchmark_class() {
    local benchmark="$1"
    echo "${BENCHMARK_CLASSES[$benchmark]:-}"
}

get_strategy_object() {
    local strategy="$1"

    case "$strategy" in
        locationOfNew)    echo "TextualLocationOfNewStrategy new" ;;
        callerOfNew)      echo "CallerOfNewStrategy new" ;;
        applicationMethod)
            local benchmark_class="$2"
            echo "ApplicationMethodStrategy setUpForApplicationPackages: $benchmark_class applicationPackages"
            ;;
        *) return 1 ;;
    esac
}

rewrite_senders() {
    local image_path="$1"
    local benchmark="$2"
    local strategy="$3"

    local benchmark_class
    benchmark_class=$(get_benchmark_class "$benchmark")

    local strategy_object
    strategy_object=$(get_strategy_object "$strategy" "$benchmark_class")

    local pharo_script="PSPRunner new strategy: ($strategy_object); benchmarkClass: $benchmark_class; pretenurePaths"
    "$PHARO_CMD" --headless "$image_path" eval --save "$pharo_script"
    echo "Rewritten code for $benchmark_class using strategy $strategy"
    echo; echo
}

download_spec2_book() {
    local target_dir="$1"

    TMP_CLONE_DIR=$(mktemp -d)
    git clone --quiet --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
    mv "$TMP_CLONE_DIR" "./$target_dir/Spec2Book"
    echo "Spec2Book downloaded for $target_dir"
    echo; echo
}

move_dataset() {
    local target_dir="$1"
    local file_name="$2"

    mv "./$target_dir/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/$file_name" "./$target_dir/"
    echo "$file_name moved to $target_dir"
    echo; echo
}

install_base_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local image_name="$benchmark"
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"

        create_image "$image_name"
        install_veritas "./$image_name/$image_name.image" "$veritas_bench"
    done
}

install_strategy_images() {
    for benchmark in "${!BENCHMARK_CLASSES[@]}"; do
        local veritas_bench="${BENCHMARK_CLASSES[$benchmark]}"

        for strategy in "${STRATEGIES[@]}"; do
            local dir_name="$benchmark-$strategy"
            local image_name="$benchmark-$strategy"
            local image_path="./$dir_name/$image_name.image"

            create_image "$image_name" "$dir_name"
            install_veritas "$image_path" "$veritas_bench"
            install_path_sensitive_pretenuring "$image_path"

            case "$benchmark" in
                microdown)
                    download_spec2_book "$dir_name"
                    ;;
                dataframe)
                    move_dataset "$dir_name" "tiny_dataset.csv"
                    ;;
                moose)
                    move_dataset "$dir_name" "sbscl.json"
                    ;;
            esac

            rewrite_senders "$image_path" "$benchmark" "$strategy"
        done
    done
}

main() {
    local mode="${1:-all}"

    setup_base_image

    case "$mode" in
        base)
            install_base_images
            ;;
        strategy)
            install_strategy_images
            ;;
        all)
            install_base_images
            install_strategy_images
            ;;
        *)
            echo "Usage: $0 [base|strategy|all]"
            exit 1
            ;;
    esac
}

main "$@"
