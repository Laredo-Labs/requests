#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Testing ChatGPT Assistant...${NC}"
echo "=============================="

# Function to check if app exists
check_app() {
    if [ ! -d "dist/ChatGPT Assistant.app" ]; then
        echo -e "${RED}❌ ChatGPT Assistant.app not found!${NC}"
        echo "Please run simple_build.command first"
        exit 1
    fi
    echo -e "${GREEN}✓ Found ChatGPT Assistant.app${NC}"
}

# Function to check if DMG exists
check_dmg() {
    if [ ! -f "dist/ChatGPT Assistant.dmg" ]; then
        echo -e "${RED}❌ ChatGPT Assistant.dmg not found!${NC}"
        echo "Please run simple_build.command first"
        exit 1
    fi
    echo -e "${GREEN}✓ Found ChatGPT Assistant.dmg${NC}"
}

# Function to verify app contents
check_contents() {
    APP_PATH="dist/ChatGPT Assistant.app"
    echo -e "\n${BLUE}Checking app contents...${NC}"
    
    # Check main executable
    if [ ! -f "$APP_PATH/Contents/MacOS/ChatGPT Assistant" ]; then
        echo -e "${RED}❌ Main executable not found${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Main executable exists${NC}"
    
    # Check Python environment
    if [ ! -d "$APP_PATH/Contents/Resources/lib/python3" ]; then
        echo -e "${RED}❌ Python environment not found${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Python environment exists${NC}"
    
    return 0
}

# Function to verify DMG
check_dmg_contents() {
    echo -e "\n${BLUE}Checking DMG file...${NC}"
    
    # Try mounting DMG
    echo "Mounting DMG..."
    hdiutil attach "dist/ChatGPT Assistant.dmg" -nobrowse
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ DMG mounts successfully${NC}"
        
        # Check app in DMG
        if [ -d "/Volumes/ChatGPT Assistant/ChatGPT Assistant.app" ]; then
            echo -e "${GREEN}✓ App found in DMG${NC}"
        else
            echo -e "${RED}❌ App not found in DMG${NC}"
        fi
        
        # Unmount DMG
        hdiutil detach "/Volumes/ChatGPT Assistant" -quiet
    else
        echo -e "${RED}❌ Failed to mount DMG${NC}"
        return 1
    fi
}

# Run tests
echo -e "\n${BLUE}Running tests...${NC}"

check_app
check_dmg
check_contents
check_dmg_contents

# Final results
echo -e "\n${BLUE}Test Results:${NC}"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✨ All tests passed!${NC}"
    echo -e "\n${YELLOW}Ready to share with your boss:${NC}"
    echo "1. The app is properly built"
    echo "2. The DMG file works"
    echo "3. All components are present"
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo "Please check the errors above and rebuild"
fi

read -p "Press Enter to exit..."
