#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo -e "${BLUE}Building ChatGPT Assistant in:${NC} $DIR"
echo "================================================"

# Check Python installation
echo -e "\n${BLUE}1. Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 not found!${NC}"
    echo "Please download and install Python from: https://www.python.org/downloads/"
    read -p "Press Enter to exit..."
    exit 1
fi

# Create and activate virtual environment
echo -e "\n${BLUE}2. Setting up Python environment...${NC}"
python3 -m venv venv
source venv/bin/activate

# Install required packages
echo -e "\n${BLUE}3. Installing required packages...${NC}"
pip install --upgrade pip
pip install pyinstaller
pip install -r requirements.txt

# Create version file
echo "1.0.0" > version.txt

echo -e "\n${BLUE}4. Building application...${NC}"
python3 -m PyInstaller \
    --clean \
    --windowed \
    --name="ChatGPT Assistant" \
    --add-data="version.txt:." \
    --hidden-import=keyring.backends.macOS \
    --hidden-import=PyQt6 \
    --hidden-import=openai \
    chatgpt_app.py

# Check if build was successful
if [ ! -d "dist/ChatGPT Assistant.app" ]; then
    echo -e "${RED}Build failed! No application bundle created.${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

# Create DMG
echo -e "\n${BLUE}5. Creating installer...${NC}"
if [ -d "dist/ChatGPT Assistant.app" ]; then
    cd dist
    mkdir -p dmg_temp
    cp -r "ChatGPT Assistant.app" dmg_temp/
    
    hdiutil create -volname "ChatGPT Assistant" \
        -srcfolder dmg_temp \
        -ov -format UDZO \
        "ChatGPT Assistant.dmg"
    
    rm -rf dmg_temp
    cd ..
    
    echo -e "${GREEN}✓ DMG created successfully${NC}"
else
    echo -e "${RED}Error: Application bundle not found${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

# Deactivate virtual environment
deactivate

echo -e "\n${GREEN}✨ Build complete!${NC}"
echo
echo -e "${BLUE}Your files are ready in the dist folder:${NC}"
echo "1. ChatGPT Assistant.app - The application"
echo "2. ChatGPT Assistant.dmg - The installer"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Open the dist folder"
echo "2. Double-click 'ChatGPT Assistant.dmg'"
echo "3. Drag ChatGPT Assistant to Applications"
echo "4. Go to Applications folder"
echo "5. Right-click ChatGPT Assistant → Open → Open"
echo
echo -e "${BLUE}Need help? Check TROUBLESHOOTING.md${NC}"

# Keep window open
read -p "Press Enter to exit..."
