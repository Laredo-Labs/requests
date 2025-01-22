#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Version
VERSION="1.0.0"
BUILD_DATE=$(date +%Y%m%d)
RELEASE_NAME="ChatGPT_Assistant_${VERSION}_${BUILD_DATE}"

echo -e "${BLUE}Building ChatGPT Assistant ${VERSION}${NC}"
echo "========================================"

# Check for required tools
check_requirements() {
    REQUIRED=("python3" "pip3" "create-dmg" "iconutil")
    for cmd in "${REQUIRED[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}Error: Required command '$cmd' not found${NC}"
            if [ "$cmd" = "create-dmg" ]; then
                echo "Install with: brew install create-dmg"
            fi
            exit 1
        fi
    done
}

# Clean previous builds
clean_build() {
    echo -e "${BLUE}Cleaning previous builds...${NC}"
    rm -rf dist build *.dmg "ChatGPT Assistant.app"
}

# Create application bundle
create_app() {
    echo -e "${BLUE}Creating application bundle...${NC}"
    chmod +x create_mac_app.sh
    ./create_mac_app.sh || {
        echo -e "${RED}Failed to create application bundle${NC}"
        exit 1
    }
}

# Create DMG installer
create_dmg() {
    echo -e "${BLUE}Creating DMG installer...${NC}"
    
    # Background image for DMG
    mkdir -p build/dmg_resources
    # You can add a background image here if desired
    
    create-dmg \
        --volname "ChatGPT Assistant Installer" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "ChatGPT Assistant.app" 200 190 \
        --hide-extension "ChatGPT Assistant.app" \
        --app-drop-link 600 185 \
        "${RELEASE_NAME}.dmg" \
        "ChatGPT Assistant.app" || {
            echo -e "${RED}Failed to create DMG installer${NC}"
            exit 1
        }
}

# Create distribution folder
create_dist() {
    echo -e "${BLUE}Creating distribution package...${NC}"
    mkdir -p dist
    mv "${RELEASE_NAME}.dmg" dist/
    cp QUICK_START.md dist/README.md
}

# Main build process
main() {
    echo -e "${BLUE}Starting build process...${NC}"
    
    # Check requirements
    check_requirements
    
    # Clean previous builds
    clean_build
    
    # Create icon if script exists
    if [ -f "create_icon.sh" ]; then
        echo -e "${BLUE}Creating application icon...${NC}"
        chmod +x create_icon.sh
        ./create_icon.sh
    fi
    
    # Create application bundle
    create_app
    
    # Create DMG installer
    create_dmg
    
    # Create distribution package
    create_dist
    
    echo -e "${GREEN}Build complete!${NC}"
    echo -e "Distribution package created in: ${BLUE}dist/${RELEASE_NAME}.dmg${NC}"
    echo
    echo "Release contents:"
    ls -l dist/
}

# Run the build process
main
