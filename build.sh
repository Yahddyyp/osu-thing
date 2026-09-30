#!/bin/bash

set -euo pipefail

APP_NAME="osu-thing"
BUNDLE_IDENTIFIER="com.yahddyyp.osu-thing"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

ICON="$ROOT_DIR/Resources/$APP_NAME.icns"

info() {
  printf '==> %s\n' "$1"
}

error() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v swift >/dev/null 2>&1 ||
  error "swift is not installed"

command -v codesign >/dev/null 2>&1 ||
  error "codesign is not present"

command -v git >/dev/null 2>&1 ||
  error "git is not installed"

[[ -f "$ICON" ]] ||
  error "Icon not found: $ICON"

cd "$ROOT_DIR"

# Prefer the macOS 26 SDK.
# The macOS 27 SDK turns some SwiftUI property wrappers into macros,
# which the Command Line Tools compiler may fail to load.
PINNED_SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk"

if [[ -n "${DEVELOPER_DIR:-}" ]]; then
  SDK="$(xcrun --show-sdk-path)"
elif [[ -d "$PINNED_SDK" ]]; then
  SDK="$PINNED_SDK"
else
  SDK="$(xcrun --show-sdk-path)"
fi

SDK_COMPAT_FLAGS=()

if [[ "$SDK" == "$PINNED_SDK" ]]; then
  SDK_COMPAT_FLAGS=(
    -Xswiftc
    -Xfrontend
    -Xswiftc
    -interface-compiler-version
    -Xswiftc
    -Xfrontend
    -Xswiftc
    6.3.2
  )
fi

# Use the latest Git tag as the app version
VERSION="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')"
VERSION="${VERSION:-0.1.0}"

# Use the Git commit count as the build number
BUILD_NUMBER="$(git rev-list --count HEAD)"

info "Building $APP_NAME..."

# Suppress normal SwiftPM output while keeping compiler errors visible
swift build \
  -c release \
  --sdk "$SDK" \
  "${SDK_COMPAT_FLAGS[@]}" \
  >/dev/null

# Get the executable location without performing another build
BIN_PATH="$(swift build \
  -c release \
  --sdk "$SDK" \
  "${SDK_COMPAT_FLAGS[@]}" \
  --show-bin-path \
  2>/dev/null)"

EXECUTABLE="$BIN_PATH/$APP_NAME"

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

</dict>
</plist>
EOF

info "Signing app..."

codesign \
  --force \
  --deep \
  --sign - \
  "$APP_BUNDLE" \
  >/dev/null

info "Verifying app..."

codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "$APP_BUNDLE" \
  >/dev/null

echo "Built $APP_NAME.app"
echo "Binary: $MACOS_DIR/$APP_NAME"
echo "Open: open \"$APP_BUNDLE\""
