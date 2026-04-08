#!/bin/bash
# CMS2026 Mobile Template — Build Script
# Usage: ./scripts/build.sh [android|ios|both]

set -e
PLATFORM=${1:-both}

echo "🔧 CMS2026 Mobile Build — Platform: $PLATFORM"
echo "================================================"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation (if needed)
# flutter pub run build_runner build --delete-conflicting-outputs

if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
  echo ""
  echo "🤖 Building Android APK..."
  flutter build apk --release
  echo "✅ APK: build/app/outputs/flutter-apk/app-release.apk"

  echo ""
  echo "🤖 Building Android App Bundle..."
  flutter build appbundle --release
  echo "✅ AAB: build/app/outputs/bundle/release/app-release.aab"
fi

if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
  echo ""
  echo "🍎 Building iOS IPA..."
  flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
  echo "✅ IPA: build/ios/ipa/*.ipa"
fi

echo ""
echo "================================================"
echo "✅ Build complete!"
