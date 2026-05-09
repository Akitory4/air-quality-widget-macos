#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${APP_PATH:-$ROOT_DIR/build/Release/AirSense.app}"
APPCAST_DIR="${APPCAST_DIR:-$ROOT_DIR/docs}"
SIGN_UPDATE="${SPARKLE_SIGN_UPDATE:-sign_update}"
RELEASE_DOWNLOAD_BASE="${RELEASE_DOWNLOAD_BASE:-https://github.com/Akitory4/air-quality-widget-macos/releases/download}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "AirSense.app not found at $APP_PATH. Run: make release" >&2
  exit 1
fi

MARKETING_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
BUILD_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Contents/Info.plist")"
RELEASE_TAG="${RELEASE_TAG:-$MARKETING_VERSION}"
ZIP_PATH="${ZIP_PATH:-$ROOT_DIR/build/Release/AirSense-$MARKETING_VERSION.zip}"

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Update archive not found at $ZIP_PATH. Run: make package-zip" >&2
  exit 1
fi

if ! command -v "$SIGN_UPDATE" >/dev/null 2>&1; then
  echo "Sparkle sign_update tool not found. Set SPARKLE_SIGN_UPDATE=/path/to/sign_update." >&2
  exit 1
fi

if [[ -n "${SPARKLE_PRIVATE_ED_KEY:-}" ]]; then
  SIGNATURE_ATTRIBUTES="$(printf '%s' "$SPARKLE_PRIVATE_ED_KEY" | "$SIGN_UPDATE" --ed-key-file - "$ZIP_PATH" | tr -d '\n')"
else
  SIGNATURE_ATTRIBUTES="$("$SIGN_UPDATE" "$ZIP_PATH" | tr -d '\n')"
fi
DOWNLOAD_URL="$RELEASE_DOWNLOAD_BASE/$RELEASE_TAG/AirSense-$MARKETING_VERSION.zip"
PUB_DATE="$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S %z')"

mkdir -p "$APPCAST_DIR"

cat > "$APPCAST_DIR/appcast.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>AirSense Updates</title>
    <link>https://github.com/Akitory4/air-quality-widget-macos/releases</link>
    <description>AirSense release feed.</description>
    <language>en</language>
    <item>
      <title>Version $MARKETING_VERSION</title>
      <link>https://github.com/Akitory4/air-quality-widget-macos/releases/tag/$RELEASE_TAG</link>
      <sparkle:version>$BUILD_VERSION</sparkle:version>
      <sparkle:shortVersionString>$MARKETING_VERSION</sparkle:shortVersionString>
      <pubDate>$PUB_DATE</pubDate>
      <enclosure url="$DOWNLOAD_URL" $SIGNATURE_ATTRIBUTES type="application/octet-stream" />
    </item>
  </channel>
</rss>
XML

echo "Generated $APPCAST_DIR/appcast.xml"
