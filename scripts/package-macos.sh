#!/bin/bash
set -euo pipefail

APP_NAME="SnapRun"
SPM_TARGET="TaskTickApp"
CLI_TARGET="tasktick"
BUNDLE_ID="com.lifedever.TaskTick"
MIN_MACOS="14.0"

VERSION="${1:-0.0.0-ci}"
OUTPUT_ROOT="${2:-.release-ci}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/${OUTPUT_ROOT}"
BUILD_DIR="${OUTPUT_DIR}/build"
APP_BUNDLE="${OUTPUT_DIR}/${APP_NAME}.app"
ICON_PATH="${PROJECT_ROOT}/Sources/Resources/AppIcon.icns"

detect_arch() {
  local raw
  raw="$(uname -m)"
  case "${raw}" in
    arm64|aarch64) echo "arm64" ;;
    x86_64|amd64) echo "x86_64" ;;
    *)
      echo "Unsupported macOS architecture: ${raw}" >&2
      exit 1
      ;;
  esac
}

find_executable() {
  local name="$1"
  local path=""

  while IFS= read -r candidate; do
    if [[ -x "${candidate}" ]]; then
      path="${candidate}"
      break
    fi
  done < <(find "${BUILD_DIR}" -type f -name "${name}" ! -path "*.dSYM/*" ! -path "*.bundle/*")

  if [[ -z "${path}" ]]; then
    echo "Could not locate executable '${name}' under ${BUILD_DIR}" >&2
    exit 1
  fi

  echo "${path}"
}

ARCH="$(detect_arch)"
DMG_PATH="${OUTPUT_DIR}/${APP_NAME}-${VERSION}-${ARCH}.dmg"
DMG_STAGING="${OUTPUT_DIR}/dmg-staging"

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "Packaging ${APP_NAME} ${VERSION} for ${ARCH}"

swift build \
  --package-path "${PROJECT_ROOT}" \
  --configuration release \
  --build-path "${BUILD_DIR}"

GUI_BIN="$(find_executable "${SPM_TARGET}")"
CLI_BIN="$(find_executable "${CLI_TARGET}")"

mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
mkdir -p "${APP_BUNDLE}/Contents/cli"

cp "${GUI_BIN}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "${CLI_BIN}" "${APP_BUNDLE}/Contents/cli/${CLI_TARGET}"

while IFS= read -r bundle; do
  cp -R "${bundle}" "${APP_BUNDLE}/"
done < <(find "${BUILD_DIR}" -type d -name "*.bundle" ! -path "*.dSYM/*")

if [[ -f "${ICON_PATH}" ]]; then
  cp "${ICON_PATH}" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

cat > "${APP_BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MIN_MACOS}</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
    <key>LSUIElement</key>
    <false/>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>zh-Hans</string>
    </array>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.lifedever.TaskTick.urlscheme</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>tasktick</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
PLIST

codesign --force --deep --no-strict --sign - "${APP_BUNDLE}"

rm -rf "${DMG_STAGING}"
mkdir -p "${DMG_STAGING}"
cp -R "${APP_BUNDLE}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${DMG_STAGING}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}" \
  -quiet

rm -rf "${DMG_STAGING}"
rm -rf "${BUILD_DIR}"

echo "Created:"
echo "  ${APP_BUNDLE}"
echo "  ${DMG_PATH}"
