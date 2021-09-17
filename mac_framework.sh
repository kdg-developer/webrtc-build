 #!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_NAME="WebRTC"

ARM_DIR="${SCRIPT_DIR}/arm64/release"
INTEL_DIR="${SCRIPT_DIR}/x86_64/release"
OUTPUT_DIR="${SCRIPT_DIR}/out_xcframework"

ARM_FRAMEWORK_PATH="${ARM_DIR}/${PROJECT_NAME}.framework"
ARM_DSYM_PATH="${ARM_DIR}/${PROJECT_NAME}.dSYM"
INTEL_FRAMEWORK_PATH="${INTEL_DIR}/${PROJECT_NAME}.framework"
INTEL_DSYM_PATH="${INTEL_DIR}/${PROJECT_NAME}.dSYM"

OUTPUT_FRAMEWORK_PATH="${OUTPUT_DIR}/${PROJECT_NAME}.framework"
OUTPUT_DSYM_PATH="${OUTPUT_DIR}/${PROJECT_NAME}.framework.dSYM"
OUTPUT_XCFRAMEWORK_PATH="${OUTPUT_DIR}/${PROJECT_NAME}.xcframework"

######################
# Clean Up
######################

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

######################
# Make an universal binary
######################

echo 'Creating WebRTC.framework'
mkdir -p ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Headers
mkdir -p ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Modules
mkdir -p ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Resources
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Headers/* ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Headers/.
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Modules/* ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Modules/.
cp -rf ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/Resources/* ${OUTPUT_FRAMEWORK_PATH}/Versions/A/Resources/.
lipo ${ARM_DIR}/${PROJECT_NAME}.framework/Versions/A/${PROJECT_NAME} ${INTEL_DIR}/${PROJECT_NAME}.framework/Versions/A/${PROJECT_NAME} -create -output ${OUTPUT_FRAMEWORK_PATH}/Versions/A/${PROJECT_NAME}
lipo -info ${OUTPUT_FRAMEWORK_PATH}/Versions/A/${PROJECT_NAME}

pushd ${OUTPUT_FRAMEWORK_PATH}
  ln -s Versions/Current/Headers Headers
  ln -s Versions/Current/Modules Modules
  ln -s Versions/Current/Resources Resources
  ln -s Versions/Current/${PROJECT_NAME} ${PROJECT_NAME}
popd

pushd ${OUTPUT_FRAMEWORK_PATH}/Versions
  ln -s A Current
popd

######################
# Make an Universal dSYM
######################

echo 'Creating dSYM'
mkdir -p ${OUTPUT_DSYM_PATH}
mkdir -p ${OUTPUT_DSYM_PATH}/Contents/Resources/DWARF

cp -rf "$ARM_DSYM_PATH/" "$OUTPUT_DSYM_PATH/."
lipo "${ARM_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}" "${INTEL_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}" \
  -create -output "${OUTPUT_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}"
lipo -info "${OUTPUT_DSYM_PATH}/Contents/Resources/DWARF/${PROJECT_NAME}"

######################
# Make an xcframework
######################

echo 'Creating xcframework'
xcodebuild -create-xcframework \
            -framework ${OUTPUT_FRAMEWORK_PATH} -debug-symbols ${OUTPUT_DSYM_PATH} \
            -output ${OUTPUT_XCFRAMEWORK_PATH}
