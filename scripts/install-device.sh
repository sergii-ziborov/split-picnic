#!/bin/sh
set -eu
# Build and install onto a connected physical iPhone.
if [ "$#" -ne 1 ] || [ -z "${DEVELOPMENT_TEAM:-}" ]; then
  printf 'Usage: DEVELOPMENT_TEAM=<your Apple team ID> %s <device ID>\n' "$0" >&2
  printf 'Find the device ID with: xcrun devicectl list devices\n' >&2
  exit 2
fi

cd "$(dirname "$0")/.."
APP="DerivedDataDevice/Build/Products/Debug-iphoneos/SplitPicnic.app"
DEVICE="$1"

xcodebuild -project SplitPicnic.xcodeproj \
  -scheme SplitPicnic \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath DerivedDataDevice \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  build

xcrun devicectl device install app --timeout 180 --device "$DEVICE" "$APP"
xcrun devicectl device process launch --device "$DEVICE" com.sergiiziborov.splitpicnic
