#! /bin/bash
set -e errexit
set -o pipefail

#IOS_DEST="platform=iOS Simulator,name=iPhone 6,OS=latest"
IOS_DEST=id=`instruments -s devices | grep "iPhone" | grep "Simulator" | tail -1 | grep -o "\[.*\]" | tr -d "[]"`
PROJ_NAME="EonilSignet"

xcodebuild -scheme "$PROJ_NAME"-iOS -destination "$IOS_DEST" -configuration Debug clean build test
xcodebuild -scheme "$PROJ_NAME"-iOS -destination "$IOS_DEST" -configuration Release clean build

xcodebuild -scheme "$PROJ_NAME"-macOS -configuration Debug clean build test
xcodebuild -scheme "$PROJ_NAME"-macOS -configuration Release clean build

swift package clean
swift build
swift test
