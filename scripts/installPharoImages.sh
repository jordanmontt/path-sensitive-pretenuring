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
local jsonFileName="$2"
"$PHARO_CMD" --headless "$image_path" eval --save "PathSensitvePretenuringExperiment new deserializeSendersToPretenureFrom: '$jsonFileName'; rewriteAllocationSites"
}

setup_base_image() {
mkdir -p baseimage
cd baseimage || return 1
wget --quiet -O - get.pharo.org/140+vm | bash
cd - > /dev/null || return 1
echo; echo; echo
echo "Baseimage downloaded"
}


######
# Download baseimage
setup_base_image


############
# Cormas — applicationMethod
mkdir -p cormas-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-applicationMethod/cormas-applicationMethod
cp "$BASE_DIR"/*.sources ./cormas-applicationMethod/
install_veritas_and_senders_rewriter_for ./cormas-applicationMethod/cormas-applicationMethod.image VeritasCormas
mv ./cormas-applicationMethod/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/cormas-applicationMethod.json ./cormas-applicationMethod/
rewrite_senders ./cormas-applicationMethod/cormas-applicationMethod.image cormas-applicationMethod.json
echo; echo; echo
echo "cormas-applicationMethod.json copied"

############
# Cormas — callerOfNew
mkdir -p cormas-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-callerOfNew/cormas-callerOfNew
cp "$BASE_DIR"/*.sources ./cormas-callerOfNew/
install_veritas_and_senders_rewriter_for ./cormas-callerOfNew/cormas-callerOfNew.image VeritasCormas
mv ./cormas-callerOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/cormas-callerOfNew.json ./cormas-callerOfNew/
rewrite_senders ./cormas-callerOfNew/cormas-callerOfNew.image cormas-callerOfNew.json
echo; echo; echo
echo "cormas-callerOfNew.json copied"

############
# Cormas — locationOfNew
mkdir -p cormas-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../cormas-locationOfNew/cormas-locationOfNew
cp "$BASE_DIR"/*.sources ./cormas-locationOfNew/
install_veritas_and_senders_rewriter_for ./cormas-locationOfNew/cormas-locationOfNew.image VeritasCormas
mv ./cormas-locationOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/cormas-locationOfNew.json ./cormas-locationOfNew/
rewrite_senders ./cormas-locationOfNew/cormas-locationOfNew.image cormas-locationOfNew.json
echo; echo; echo
echo "cormas-locationOfNew.json copied"

############
# Microdown — applicationMethod
mkdir -p microdown-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-applicationMethod/microdown-applicationMethod
cp "$BASE_DIR"/*.sources ./microdown-applicationMethod/
install_veritas_and_senders_rewriter_for ./microdown-applicationMethod/microdown-applicationMethod.image VeritasMicrodown
mv ./microdown-applicationMethod/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/microdown-applicationMethod.json ./microdown-applicationMethod/
rewrite_senders ./microdown-applicationMethod/microdown-applicationMethod.image microdown-applicationMethod.json
echo; echo; echo
echo "microdown-applicationMethod.json copied"
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-applicationMethod/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-applicationMethod"

############
# Microdown — callerOfNew
mkdir -p microdown-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-callerOfNew/microdown-callerOfNew
cp "$BASE_DIR"/*.sources ./microdown-callerOfNew/
install_veritas_and_senders_rewriter_for ./microdown-callerOfNew/microdown-callerOfNew.image VeritasMicrodown
mv ./microdown-callerOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/microdown-callerOfNew.json ./microdown-callerOfNew/
rewrite_senders ./microdown-callerOfNew/microdown-callerOfNew.image microdown-callerOfNew.json
echo; echo; echo
echo "microdown-callerOfNew.json copied"
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-callerOfNew/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-callerOfNew"

############
# Microdown — locationOfNew
mkdir -p microdown-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../microdown-locationOfNew/microdown-locationOfNew
cp "$BASE_DIR"/*.sources ./microdown-locationOfNew/
install_veritas_and_senders_rewriter_for ./microdown-locationOfNew/microdown-locationOfNew.image VeritasMicrodown
mv ./microdown-locationOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/microdown-locationOfNew.json ./microdown-locationOfNew/
rewrite_senders ./microdown-locationOfNew/microdown-locationOfNew.image microdown-locationOfNew.json
echo; echo; echo
echo "microdown-locationOfNew.json copied"
# download Spec2 book
TMP_CLONE_DIR=$(mktemp -d)
git clone --depth=1 https://github.com/SquareBracketAssociates/BuildingApplicationWithSpec2.git "$TMP_CLONE_DIR"
mv "$TMP_CLONE_DIR" ./microdown-locationOfNew/Spec2Book
echo; echo; echo
echo "Spec2Book downloaded for microdown-locationOfNew"

############
# DataFrame — applicationMethod
mkdir -p dataframe-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-applicationMethod/dataframe-applicationMethod
cp "$BASE_DIR"/*.sources ./dataframe-applicationMethod/
install_veritas_and_senders_rewriter_for ./dataframe-applicationMethod/dataframe-applicationMethod.image VeritasDataFrame
mv ./dataframe-applicationMethod/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/dataframe-applicationMethod.json ./dataframe-applicationMethod/
rewrite_senders ./dataframe-applicationMethod/dataframe-applicationMethod.image dataframe-applicationMethod.json
echo; echo; echo
echo "dataframe-applicationMethod.json copied"
mv ./dataframe-applicationMethod/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/src/Veritas-DataFrame/tiny_dataset.csv ./dataframe-applicationMethod/
echo; echo; echo
echo "dataset copied for dataframe-applicationMethod"

############
# DataFrame — callerOfNew
mkdir -p dataframe-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-callerOfNew/dataframe-callerOfNew
cp "$BASE_DIR"/*.sources ./dataframe-callerOfNew/
install_veritas_and_senders_rewriter_for ./dataframe-callerOfNew/dataframe-callerOfNew.image VeritasDataFrame
mv ./dataframe-callerOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/dataframe-callerOfNew.json ./dataframe-callerOfNew/
rewrite_senders ./dataframe-callerOfNew/dataframe-callerOfNew.image dataframe-callerOfNew.json
echo; echo; echo
echo "dataframe-callerOfNew.json copied"
mv ./dataframe-callerOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/src/Veritas-DataFrame/tiny_dataset.csv ./dataframe-callerOfNew/
echo; echo; echo
echo "dataset copied for dataframe-callerOfNew"

############
# DataFrame — locationOfNew
mkdir -p dataframe-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../dataframe-locationOfNew/dataframe-locationOfNew
cp "$BASE_DIR"/*.sources ./dataframe-locationOfNew/
install_veritas_and_senders_rewriter_for ./dataframe-locationOfNew/dataframe-locationOfNew.image VeritasDataFrame
mv ./dataframe-locationOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/dataframe-locationOfNew.json ./dataframe-locationOfNew/
rewrite_senders ./dataframe-locationOfNew/dataframe-locationOfNew.image dataframe-locationOfNew.json
echo; echo; echo
echo "dataframe-locationOfNew.json copied"
mv ./dataframe-locationOfNew/pharo-local/iceberg/jordanmontt/PharoVeritasBenchSuite/src/Veritas-DataFrame/tiny_dataset.csv ./dataframe-locationOfNew/
echo; echo; echo
echo "dataset copied for dataframe-locationOfNew"

############
# Moose — applicationMethod
mkdir -p moose-applicationMethod
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-applicationMethod/moose-applicationMethod
cp "$BASE_DIR"/*.sources ./moose-applicationMethod/
install_veritas_and_senders_rewriter_for ./moose-applicationMethod/moose-applicationMethod.image VeritasMoose
mv ./moose-applicationMethod/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/moose-applicationMethod.json ./moose-applicationMethod/
rewrite_senders ./moose-applicationMethod/moose-applicationMethod.image moose-applicationMethod.json
echo; echo; echo
echo "moose-applicationMethod.json copied"

############
# Moose — callerOfNew
mkdir -p moose-callerOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-callerOfNew/moose-callerOfNew
cp "$BASE_DIR"/*.sources ./moose-callerOfNew/
install_veritas_and_senders_rewriter_for ./moose-callerOfNew/moose-callerOfNew.image VeritasMoose
mv ./moose-callerOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/moose-callerOfNew.json ./moose-callerOfNew/
rewrite_senders ./moose-callerOfNew/moose-callerOfNew.image moose-callerOfNew.json
echo; echo; echo
echo "moose-callerOfNew.json copied"

############
# Moose — locationOfNew
mkdir -p moose-locationOfNew
"$PHARO_CMD" --headless "$BASE_IMAGE_FILE" save ../moose-locationOfNew/moose-locationOfNew
cp "$BASE_DIR"/*.sources ./moose-locationOfNew/
install_veritas_and_senders_rewriter_for ./moose-locationOfNew/moose-locationOfNew.image VeritasMoose
mv ./moose-locationOfNew/pharo-local/iceberg/jordanmontt/path-sensitive-pretenuring/files/paths-to-pretenure/moose-locationOfNew.json ./moose-locationOfNew/
rewrite_senders ./moose-locationOfNew/moose-locationOfNew.image moose-locationOfNew.json
echo; echo; echo
echo "moose-locationOfNew.json copied"