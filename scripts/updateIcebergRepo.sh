BASE_DIR="baseimage"
BASE_IMAGE_FILE="$BASE_DIR/Pharo.image"
PHARO_CMD="$BASE_DIR/pharo"

### Define repo name!
repo_name=""

code="|repo| repo := IceRepository registry detect: [ :each | each name = '$repo_name' ].[ repo pull ] on:
IceExperimentalFeature do:[ :ex | ex resume ].repo loadedPackages do: [ :pkg |  [ pkg reload ] on: MCMergeOrLoadWarning
do: [ :ex | ex load].]."

# Functions
update_iceberg() {
	local image_path="$1"
	
	"$PHARO_CMD" --headless "$image_path" eval --save "$code"

	echo
	echo "Updated path sensitive repo for image $image_path"
	echo; echo; echo
}

# Image list
images=(
  cormas-applicationMethod
  cormas-callerOfNew
  cormas-locationOfNew
  microdown-applicationMethod
  microdown-callerOfNew
  microdown-locationOfNew
  dataframe-applicationMethod
  dataframe-callerOfNew
  dataframe-locationOfNew
  moose-applicationMethod
  moose-callerOfNew
  moose-locationOfNew
)

# Loop
for img in "${images[@]}"; do
  update_iceberg "./$img/$img.image"
done