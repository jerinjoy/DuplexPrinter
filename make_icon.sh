#!/bin/bash
set -e
SRC="/Users/joy/.gemini/antigravity/brain/83153303-ce4a-4cb4-9809-3363849cf7bb/app_icon_final_1772336336390.png"
mkdir -p AppIcon.iconset
sips -z 16 16     "$SRC" --out AppIcon.iconset/icon_16x16.png
sips -z 32 32     "$SRC" --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32     "$SRC" --out AppIcon.iconset/icon_32x32.png
sips -z 64 64     "$SRC" --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128   "$SRC" --out AppIcon.iconset/icon_128x128.png
sips -z 256 256   "$SRC" --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256   "$SRC" --out AppIcon.iconset/icon_256x256.png
sips -z 512 512   "$SRC" --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512   "$SRC" --out AppIcon.iconset/icon_512x512.png
sips -z 1024 1024 "$SRC" --out AppIcon.iconset/icon_512x512@2x.png
iconutil -c icns AppIcon.iconset
rm -R AppIcon.iconset
