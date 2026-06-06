#!/bin/bash
set -e

echo "🔧 Starting CI post-clone setup..."

# Navigate to root
cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "📥 Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "✅ Flutter installed. Version:"
flutter --version

echo "🏥 Running flutter doctor..."
flutter doctor

echo "⬇️ Precaching iOS artifacts..."
flutter precache --ios

echo "📦 Installing dependencies and regenerating config..."
flutter pub get

# CRITICAL: Regenerate Generated.xcconfig with correct paths for CI
echo "🔧 Regenerating Flutter build config..."
cd ios
rm -f Flutter/Generated.xcconfig
cd ..
flutter clean
flutter pub get

echo "🍫 Installing CocoaPods..."
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods || echo "CocoaPods may already be installed"

echo "📚 Installing project pods..."
cd ios
pod repo update
pod install --repo-update

echo "✅ CI post-clone setup completed!"