#!/bin/sh
set -e

echo "Installing Flutter dependencies"
flutter pub get

echo "Installing CocoaPods"
cd ios
pod install