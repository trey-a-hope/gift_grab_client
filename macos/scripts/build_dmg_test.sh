#!/usr/bin/env bash
set -e

# Use Codemagic's build dir if available, otherwise resolve from script location
if [ -n "$CM_BUILD_DIR" ]; then
  PROJECT_DIR="$CM_BUILD_DIR"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
fi

echo "PROJECT_DIR: $PROJECT_DIR"

# Delete stale keychain if exists
security delete-keychain build.keychain 2>/dev/null || true

# Import Developer ID cert
printf "%s" "$DEVELOPER_ID_P12" | base64 --decode > /tmp/developer_id.p12
security create-keychain -p "" build.keychain
security list-keychains -d user -s build.keychain ~/Library/Keychains/login.keychain-db
security default-keychain -s build.keychain
security unlock-keychain -p "" build.keychain
security import /tmp/developer_id.p12 \
  -k build.keychain \
  -P "$DEVELOPER_ID_P12_PASSWORD" \
  -T /usr/bin/codesign
security set-key-partition-list \
  -S apple-tool:,apple:,codesign: \
  -s -k "" \
  build.keychain

security find-identity -v -p codesigning

# App configurations
APP_NAME="Gift Grab"
DMG_FILENAME="$APP_NAME"
IDENTITY="Developer ID Application: Tr3umphant.Designs, LLC (AYXEVPG9Z5)"
APP_PATH=$(find "$PROJECT_DIR/build/macos/Build/Products/Release" -name "*.app" | head -1)
DMG_PATH="$PROJECT_DIR/$DMG_FILENAME.dmg"

echo "APP_PATH: $APP_PATH"
echo "DMG_PATH: $DMG_PATH"

# Ensure execution bits are preserved on the main binary inside Contents/MacOS
chmod -R +x "$APP_PATH/Contents/MacOS/"

# Deep sign entire bundle with hardened runtime (matching your working script)
codesign --deep --force --verify --verbose \
  --sign "$IDENTITY" \
  --options runtime \
  "$APP_PATH"

# Re-enforce executable permissions post-signing
chmod -R +x "$APP_PATH/Contents/MacOS/"

# Verify signature locally before packaging
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

# Setup DMG staging directory with Applications link
STAGING_DIR="/tmp/dmg_staging_$(date +%s)"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$DMG_PATH"

# Create DMG
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGING_DIR"

# Submit DMG for Apple Notarization
xcrun notarytool submit "$DMG_PATH" \
  --apple-id "trey.a.hope@gmail.com" \
  --team-id "AYXEVPG9Z5" \
  --password "$APP_SPECIFIC_PASSWORD" \
  --wait

# Staple ticket to the DMG
xcrun stapler staple "$DMG_PATH"

# Copy DMG to artifacts (Codemagic CI environment)
if [ -n "$CM_BUILD_DIR" ]; then
  mkdir -p "$CM_EXPORT_DIR"
  cp "$DMG_PATH" "$CM_EXPORT_DIR/$DMG_FILENAME.dmg"
fi