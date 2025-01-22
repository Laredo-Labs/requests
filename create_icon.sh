#!/bin/bash

# Required commands
COMMANDS=("svg2png" "iconutil" "mkdir" "cp")

# Check for required commands
for cmd in "${COMMANDS[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' is not installed."
        if [ "$cmd" = "svg2png" ]; then
            echo "Install with: npm install -g svg2png-cli"
        fi
        exit 1
    fi
done

# Create temporary iconset directory
ICONSET="icon.iconset"
mkdir -p "$ICONSET"

# Convert SVG to PNG at different sizes
sizes=(16 32 64 128 256 512 1024)
for size in "${sizes[@]}"; do
    # Regular size
    svg2png -w $size -h $size icon.svg "$ICONSET/icon_${size}x${size}.png"
    
    # @2x size (if not the largest size)
    if [ $size -lt 512 ]; then
        double_size=$((size * 2))
        svg2png -w $double_size -h $double_size icon.svg "$ICONSET/icon_${size}x${size}@2x.png"
    fi
done

# Rename files to match Apple's requirements
mv "$ICONSET/icon_16x16.png" "$ICONSET/icon_16x16.png"
mv "$ICONSET/icon_32x32.png" "$ICONSET/icon_32x32.png"
mv "$ICONSET/icon_32x32@2x.png" "$ICONSET/icon_32x32@2x.png"
mv "$ICONSET/icon_128x128.png" "$ICONSET/icon_128x128.png"
mv "$ICONSET/icon_128x128@2x.png" "$ICONSET/icon_128x128@2x.png"
mv "$ICONSET/icon_256x256.png" "$ICONSET/icon_256x256.png"
mv "$ICONSET/icon_256x256@2x.png" "$ICONSET/icon_256x256@2x.png"
mv "$ICONSET/icon_512x512.png" "$ICONSET/icon_512x512.png"
mv "$ICONSET/icon_512x512@2x.png" "$ICONSET/icon_512x512@2x.png"

# Create icns file
iconutil -c icns "$ICONSET"

# Clean up
rm -rf "$ICONSET"

echo "Icon created successfully: icon.icns"
