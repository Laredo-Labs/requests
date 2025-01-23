#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo -e "${BLUE}Starting setup and build process...${NC}"
echo "========================================"

# Function for error handling
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    read -p "Press Enter to exit..."
    exit 1
}

# Step 1: Make scripts executable
echo -e "\n${BLUE}1. Making scripts executable...${NC}"
chmod +x *.command *.sh || handle_error "Couldn't make scripts executable"
echo -e "${GREEN}✓ Made scripts executable${NC}"

# Step 2: Verify Python
echo -e "\n${BLUE}2. Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    handle_error "Python 3 not found. Please install from python.org"
fi
echo -e "${GREEN}✓ Python found${NC}"

# Step 3: Set up virtual environment
echo -e "\n${BLUE}3. Setting up Python environment...${NC}"
python3 -m venv venv || handle_error "Failed to create virtual environment"
source venv/bin/activate || handle_error "Failed to activate virtual environment"
echo -e "${GREEN}✓ Environment ready${NC}"

# Step 4: Install requirements
echo -e "\n${BLUE}4. Installing requirements...${NC}"
pip install --upgrade pip || handle_error "Failed to upgrade pip"
pip install -r requirements.txt || handle_error "Failed to install requirements"
echo -e "${GREEN}✓ Requirements installed${NC}"

# Step 5: Build the app
echo -e "\n${BLUE}5. Building application...${NC}"
./build_app.command || handle_error "Build failed"

# Step 6: Run tests
echo -e "\n${BLUE}6. Running tests...${NC}"
./test_app.command || handle_error "Tests failed"

echo -e "\n${GREEN}✨ Setup and build complete!${NC}"
echo
echo -e "${BLUE}Your files are in:${NC}"
echo "dist/ChatGPT Assistant.app"
echo "dist/ChatGPT Assistant.dmg"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Double-click ChatGPT Assistant.dmg"
echo "2. Drag to Applications"
echo "3. Right-click app → Open"
echo
read -p "Press Enter to exit..."
