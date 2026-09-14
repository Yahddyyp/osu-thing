#!/bin/bash

set -euo pipefail

APP_NAME="osu-thing"
BUNDLE_IDENTIFIER="com.osu-thing.app"

VERSION="${1:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

EXECUTABLE="$ROOT_DIR/.build/release/$APP_NAME"
ICON="$ROOT_DIR/assets/$APP_NAME.icns"

info() {
  printf '==> %s\n' "$1"
}

error() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v swift >/dev/null 2>&1 ||
  error "Swift is required"

command -v codesign >/dev/null 2>&1 ||
  error "codesign is required"

[[ -f "$ICON" ]] ||
  error "Icon not found: $ICON"

cd "$ROOT_DIR"

info "Building $APP_NAME..."

swift build -c release

[[ -f "$EXECUTABLE" ]] ||
  error "Build succeeded, but executable was not found"

info "Creating app bundle..."

rm -rf "$APP_BUNDLE"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

info "Copying executable..."

cp "$EXECUTABLE" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

info "Copying icon..."

cp "$ICON" "$RESOURCES_DIR/$APP_NAME.icns"

info "Creating Info.plist..."

cat >"$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

    <key>CFBundleName</key>
    <string>$APP_NAME</string>

    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>

    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_IDENTIFIER</string>

    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>

    <key>CFBundleIconFile</key>
    <string>$APP_NAME.icns</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>

    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>

    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>

    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>

</dict>
</plist>
EOF

info "Signing app..."

codesign \
  --force \
  --deep \
  --sign - \
  "$APP_BUNDLE"

info "Verifying app..."

codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "$APP_BUNDLE"

echo
echo "Built $APP_NAME.app"
echo
echo "Version:     $VERSION"
echo "Build:       $BUILD_NUMBER"
echo "Location:    $APP_BUNDLE"
echo
echo "Run with:"
echo "  open \"$APP_BUNDLE\""
