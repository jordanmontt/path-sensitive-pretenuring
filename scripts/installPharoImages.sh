#########
# This script fully automates the downloading and the installion of different veritas benchs in different pharo images. Perfect for using in a server.
# This example shows just to download and install Phaor images.
# The scripts copies one image per project, install its corresponding baseline and if necessary makes some preprocessing.
# For example for the DataFrame banchmark we need th datasets, meaning the csv files. This script takes the file that comes by default, the smallest one, and puts it into the image directory which is the right place to put. If you want the bigger datasets you need to generate them using the python file present in the code. Chech in src.
# For the Microdowm image it download the spec book from another repo and then moves the folder.
# Variables
BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

# Functions
install_veritas_and_senders_rewriter_for() {
local image_path="$1"
local veritas_bench="$2"
"$PHARO_CMD" --headless "$image_path" metacello install --save "github://jordanmontt/PharoVeritasBenchSuite:main" "$veritas_bench"
echo; echo; echo
echo "Installed Veritas $veritas_bench for image $image_path"

"$PHARO_CMD" --headless "$image_path" metacello install --save "github://jordanmontt//path-sensitive-pretenuring:main" "PathSensitivePretenuring"
echo; echo; echo
echo "Installed Path Sensitive Pretenuring $veritas_bench for image $image_path"
}

rewrite_senders() {
    local image_path="$1"
    local benchmark="$2"
    local strategy="$3"

    local benchmarkClass
    case "$benchmark" in
        cormas)      benchmarkClass="VeritasCormas" ;;
        moose)       benchmarkClass="VeritasMoose" ;;
        dataframe)   benchmarkClass="VeritasDataFrame" ;;
        microdown)   benchmarkClass="VeritasMicrodown" ;;
        *)
            echo "Unknown benchmark: $benchmark" >&2
            return 1
            ;;
    esac

    local strategyObject
    case "$strategy" in
        locationOfNew)    strategyObject="TextualLocationOfNewStrategy new" ;;
        callerOfNew)      strategyObject="CallerOfNewStrategy new" ;;
        applicationMethod) strategyObject="ApplicationMethodStrategy setUpForApplicationPackages: ${benchmarkClass} applicationPackages" ;;
        *)
            echo "Unknown strategy: $strategy" >&2
            return 1
            ;;
    esac

    "$PHARO_CMD" --headless "$image_path" eval --save \
        "PSPRunner new strategy: ($strategyObject); benchmarkClass: $benchmarkClass; pretenurePaths"

    echo "Rewritten code for pretenuring paths"
    echo; echo; echo
}

setup_base_image() {
mkdir -p baseimage
cd baseimage || return 1
wget --quiet -O - get.pharo.org/140+vm | bash
cd - > /dev/null || return 1
echo; echo; echo
echo "Baseimage downloaded"
}


#####
Download baseimage
setup_base_image


###########
# Cormas — applicationMethod
mkdir -p cormas-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-applicationMethod/cormas-applicationMethod
cp "$BASE_DIR"/*.sources ./cormas-applicationMethod/
install_veritas_and_senders_rewriter_for ./cormas-applicationMethod/cormas-applicationMethod.image VeritasCormas
rewrite_senders ./cormas-applicationMethod/cormas-applicationMethod.image cormas applicationMethod

############
# Cormas — callerOfNew
mkdir -p cormas-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-callerOfNew/cormas-callerOfNew
cp "$BASE_DIR"/*.sources ./cormas-callerOfNew/
install_veritas_and_senders_rewriter_for ./cormas-callerOfNew/cormas-callerOfNew.image VeritasCormas
rewrite_senders ./cormas-callerOfNew/cormas-callerOfNew.image cormas callerOfNew

############
# Cormas — locationOfNew
mkdir -p cormas-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-locationOfNew/cormas-locationOfNew
cp "$BASE_DIR"/*.sources ./cormas-locationOfNew/
install_veritas_and_senders_rewriter_for ./cormas-locationOfNew/cormas-locationOfNew.image VeritasCormas
rewrite_senders ./cormas-locationOfNew/cormas-locationOfNew.image cormas locationOfNew

############
# Microdown — applicationMethod
mkdir -p microdown-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-applicationMethod/microdown-applicationMethod
cp "$BASE_DIR"/*.sources ./microdown-applicationMethod/
install_veritas_and_senders_rewriter_for ./microdown-applicationMethod/microdown-applicationMethod.image VeritasMicrodown
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-applicationMethod/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-applicationMethod"
#rewrite
rewrite_senders ./microdown-applicationMethod/microdown-applicationMethod.image microdown applicationMethod

############
# Microdown — callerOfNew
mkdir -p microdown-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-callerOfNew/microdown-callerOfNew
cp "$BASE_DIR"/*.sources ./microdown-callerOfNew/
install_veritas_and_senders_rewriter_for ./microdown-callerOfNew/microdown-callerOfNew.image VeritasMicrodown
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-callerOfNew/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-callerOfNew"
rewrite_senders ./microdown-callerOfNew/microdown-callerOfNew.image microdown callerOfNew

############
# Microdown — locationOfNew
mkdir -p microdown-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-locationOfNew/microdown-locationOfNew
cp "$BASE_DIR"/*.sources ./microdown-locationOfNew/
install_veritas_and_senders_rewriter_for ./microdown-locationOfNew/microdown-locationOfNew.image VeritasMicrodown
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-locationOfNew/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-locationOfNew"
rewrite_senders ./microdown-locationOfNew/microdown-locationOfNew.image microdown locationOfNew

############
# DataFrame — applicationMethod
mkdir -p dataframe-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-applicationMethod/dataframe-applicationMethod
cp "$BASE_DIR"/*.sources ./dataframe-applicationMethod/
install_veritas_and_senders_rewriter_for ./dataframe-applicationMethod/dataframe-applicationMethod.image VeritasDataFrame
mv ./dataframe-applicationMethod/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/tiny_dataset.csv ./dataframe-applicationMethod/
echo; echo; echo
echo "dataset copied for dataframe-applicationMethod"
rewrite_senders ./dataframe-applicationMethod/dataframe-applicationMethod.image dataframe applicationMethod

############
# DataFrame — callerOfNew
mkdir -p dataframe-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-callerOfNew/dataframe-callerOfNew
cp "$BASE_DIR"/*.sources ./dataframe-callerOfNew/
install_veritas_and_senders_rewriter_for ./dataframe-callerOfNew/dataframe-callerOfNew.image VeritasDataFrame
mv ./dataframe-callerOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/tiny_dataset.csv ./dataframe-callerOfNew/
echo; echo; echo
echo "dataset copied for dataframe-callerOfNew"
rewrite_senders ./dataframe-callerOfNew/dataframe-callerOfNew.image dataframe callerOfNew

############
# DataFrame — locationOfNew
mkdir -p dataframe-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-locationOfNew/dataframe-locationOfNew
cp "$BASE_DIR"/*.sources ./dataframe-locationOfNew/
install_veritas_and_senders_rewriter_for ./dataframe-locationOfNew/dataframe-locationOfNew.image VeritasDataFrame
mv ./dataframe-locationOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/tiny_dataset.csv ./dataframe-locationOfNew/
echo; echo; echo
echo "dataset copied for dataframe-locationOfNew"
rewrite_senders ./dataframe-locationOfNew/dataframe-locationOfNew.image dataframe locationOfNew

############
# Moose — applicationMethod
mkdir -p moose-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-applicationMethod/moose-applicationMethod
cp "$BASE_DIR"/*.sources ./moose-applicationMethod/
install_veritas_and_senders_rewriter_for ./moose-applicationMethod/moose-applicationMethod.image VeritasMoose
mv ./moose-applicationMethod/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/sbscl.json ./moose-applicationMethod/
echo; echo; echo
echo "json copied for moose-applicationMethod"
rewrite_senders ./moose-applicationMethod/moose-applicationMethod.image moose applicationMethod

############
# Moose — callerOfNew
mkdir -p moose-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-callerOfNew/moose-callerOfNew
cp "$BASE_DIR"/*.sources ./moose-callerOfNew/
install_veritas_and_senders_rewriter_for ./moose-callerOfNew/moose-callerOfNew.image VeritasMoose
mv ./moose-callerOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/sbscl.json ./moose-callerOfNew/
echo; echo; echo
echo "json copied for moose-callerOfNew"
rewrite_senders ./moose-callerOfNew/moose-callerOfNew.image moose callerOfNew

############
# Moose — locationOfNew
mkdir -p moose-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-locationOfNew/moose-locationOfNew
cp "$BASE_DIR"/*.sources ./moose-locationOfNew/
install_veritas_and_senders_rewriter_for ./moose-locationOfNew/moose-locationOfNew.image VeritasMoose
mv ./moose-locationOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/files/sbscl.json ./moose-locationOfNew/
echo; echo; echo
echo "json copied for moose-locationOfNew"
rewrite_senders ./moose-locationOfNew/moose-locationOfNew.image moose locationOfNew