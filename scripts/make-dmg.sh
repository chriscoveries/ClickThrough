#!/bin/zsh
# Packages build/ClickThrough.app into a drag-to-Applications disk image.
set -euo pipefail
cd "$(dirname "$0")/.."

APP=build/ClickThrough.app
DMG=build/ClickThrough.dmg
[[ -d "$APP" ]] || { echo "Build the app first: scripts/build-release.sh"; exit 1; }

STAGE=$(mktemp -d)/ClickThrough
mkdir -p "$STAGE"
trap 'rm -rf "$(dirname "$STAGE")"' EXIT
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

rm -f "$DMG"
if command -v hdiutil >/dev/null 2>&1; then
  # hdiutil remains the compatible UDZO writer on macOS 15 and older systems.
  # diskutil exposes 'image create from' there but rejects the UDZO format.
  hdiutil create -volname ClickThrough -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
else
  # On newer systems without hdiutil, the source folder supplies the volume name.
  diskutil image create from --format UDZO "$STAGE" "$DMG" >/dev/null
fi
echo "Built $DMG"
