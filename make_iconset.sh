#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Creating macOS icon set${NC}"

# Check for required commands
if ! command -v sips &> /dev/null || ! command -v iconutil &> /dev/null; then
    echo -e "${RED}Error: This script requires macOS command line tools${NC}"
    exit 1
fi

# Create iconset directory
ICONSET_NAME="icon.iconset"
mkdir -p "$ICONSET_NAME"

# Generate different icon sizes from the highest resolution
ORIGINAL="icon.png"

if [ ! -f "$ORIGINAL" ]; then
    # If PNG doesn't exist, try to convert SVG first
    if [ -f "icon.svg" ]; then
        # Check if rsvg-convert is available
        if command -v rsvg-convert &> /dev/null; then
            echo "Converting SVG to PNG..."
            rsvg-convert -h 1024 icon.svg > icon.png
        else
            echo -e "${RED}Error: Neither icon.png nor rsvg-convert found${NC}"
            echo "Please provide a 1024x1024 icon.png file"
            exit 1
        fi
    else
        echo -e "${RED}Error: No source icon found${NC}"
        echo "Please provide either icon.svg or a 1024x1024 icon.png file"
        exit 1
    fi
fi

# Array of sizes needed for macOS
ICON_SIZES=(16 32 64 128 256 512 1024)

# Generate each size
for size in "${ICON_SIZES[@]}"; do
    # Regular size
    sips -z $size $size "$ORIGINAL" --out "$ICONSET_NAME/icon_${size}x${size}.png" > /dev/null 2>&1
    
    # Retina size (2x) if not the largest size
    if [ $size -lt 512 ]; then
        double_size=$((size * 2))
        sips -z $double_size $double_size "$ORIGINAL" --out "$ICONSET_NAME/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    fi
done

# Rename files to match Apple's requirements
mv "$ICONSET_NAME/icon_16x16.png" "$ICONSET_NAME/icon_16x16.png"
mv "$ICONSET_NAME/icon_32x32.png" "$ICONSET_NAME/icon_32x32.png"
mv "$ICONSET_NAME/icon_32x32@2x.png" "$ICONSET_NAME/icon_32x32@2x.png"
mv "$ICONSET_NAME/icon_128x128.png" "$ICONSET_NAME/icon_128x128.png"
mv "$ICONSET_NAME/icon_128x128@2x.png" "$ICONSET_NAME/icon_128x128@2x.png"
mv "$ICONSET_NAME/icon_256x256.png" "$ICONSET_NAME/icon_256x256.png"
mv "$ICONSET_NAME/icon_256x256@2x.png" "$ICONSET_NAME/icon_256x256@2x.png"
mv "$ICONSET_NAME/icon_512x512.png" "$ICONSET_NAME/icon_512x512.png"
mv "$ICONSET_NAME/icon_512x512@2x.png" "$ICONSET_NAME/icon_512x512@2x.png"

# Create icns file
echo -e "${BLUE}Converting to icns format...${NC}"
iconutil -c icns "$ICONSET_NAME"

# Clean up
rm -rf "$ICONSET_NAME"

if [ -f "icon.icns" ]; then
    echo -e "${GREEN}Successfully created icon.icns${NC}"
else
    echo -e "${RED}Failed to create icon.icns${NC}"
    exit 1
fi
