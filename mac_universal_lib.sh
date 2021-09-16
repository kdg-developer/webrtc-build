 #!/usr/bin/env bash

PROJECT_NAME="WebRTC"

ARM_DIR="_build/macos_arm64/webrtc/release"
INTEL_DIR="_build/macos_x86_64/webrtc/release"
OUTPUT_DIR="_out"

ARM_DSYM_PATH="${ARM_DIR}/${PROJECT_NAME}.dSYM"
INTEL_DSYM_PATH="${INTEL_DIR}/${PROJECT_NAME}.dSYM"

OUTPUT_FRAMEWORK_DIR="${OUTPUT_DIR}/${PROJECT_NAME}.framework"
OUTPUT_DSYM_DIR="${OUTPUT_DIR}/${PROJECT_NAME}.framework.dSYM"

rm -rf $OUTPUT_DIR

######################
# Make an universal binary
######################

mkdir -p ${OUTPUT_FRAMEWORK_DIR}
mkdir -p ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Headers
mkdir -p ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Modules
mkdir -p ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Resources
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Headers/* ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Headers/.
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Modules/* ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Modules/.
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Resources/* ${OUTPUT_FRAMEWORK_DIR}/Versions/A/Resources/.
lipo ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/${PROJECT_NAME} ${INTEL_DIR}/${PROJECT_NAME}.framework/Versions/A/${PROJECT_NAME} -create -output ${OUTPUT_FRAMEWORK_DIR}/Versions/A/${PROJECT_NAME}
lipo -info ${OUTPUT_FRAMEWORK_DIR}/Versions/A/${PROJECT_NAME}

pushd ${OUTPUT_FRAMEWORK_DIR}
  ln -s Versions/Current/Headers Headers
  ln -s Versions/Current/Modules Modules
  ln -s Versions/Current/Resources Resources
  ln -s Versions/Current/${PROJECT_NAME} ${PROJECT_NAME}
popd

pushd ${OUTPUT_FRAMEWORK_DIR}/Versions
  ln -s A Current
popd

######################
# Make an dSYM
######################

mkdir -p ${OUTPUT_DSYM_DIR}
mkdir -p ${OUTPUT_DSYM_DIR}/Contents/Resources/DWARF

cp -rf "$ARM_DSYM_PATH/" "$OUTPUT_DSYM_DIR/."
lipo "${ARM_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}" "${INTEL_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}" \
  -create -output "${OUTPUT_DSYM_DIR}/Contents/Resources/DWARF/${PROJECT_NAME}"
lipo -info "${OUTPUT_DSYM_DIR}/Contents/Resources/DWARF/${PROJECT_NAME}"
