#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error handling
set -e
trap 'handle_error $? $LINENO' ERR

handle_error() {
    echo -e "${RED}Error $1 occurred on line $2${NC}"
    read -p "Press Enter to exit..."
    exit 1
}

# Get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo -e "${BLUE}ChatGPT Assistant Builder${NC}"
echo "=========================="

# Function to check for required tools
check_requirements() {
    echo -e "\n${BLUE}Checking requirements...${NC}"
    REQUIRED=("python3" "pip3" "git")
    
    for cmd in "${REQUIRED[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}Error: Required command '$cmd' not found${NC}"
            case $cmd in
                "python3")
                    echo "Please install Python from: https://www.python.org/downloads/"
                    ;;
                *)
                    echo "Please install $cmd and try again"
                    ;;
            esac
            exit 1
        fi
    done
}

# Function to set up Python environment
setup_environment() {
    echo -e "\n${BLUE}Setting up Python environment...${NC}"
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    pip install -r requirements.txt
}

# Function to create application icon
create_icon() {
    echo -e "\n${BLUE}Creating application icon...${NC}"
    if [ -f "make_iconset.sh" ]; then
        chmod +x make_iconset.sh
        ./make_iconset.sh
    else
        echo -e "${YELLOW}Warning: make_iconset.sh not found, skipping icon creation${NC}"
    fi
}

# Function to build the application
build_app() {
    echo -e "\n${BLUE}Building application...${NC}"
    chmod +x package_mac_app.sh
    ./package_mac_app.sh
}

# Function to create installer
create_installer() {
    echo -e "\n${BLUE}Creating installer...${NC}"
    chmod +x install.sh
    ./install.sh
}

# Main build process
main() {
    echo -e "Starting build process..."
    
    # Check requirements
    check_requirements
    
    # Setup Python environment
    setup_environment
    
    # Create icon
    create_icon
    
    # Build application
    build_app
    
    # Create installer
    create_installer
    
    echo -e "\n${GREEN}Build complete!${NC}"
    echo -e "\nYou can find:"
    echo "- The application bundle in: dist/ChatGPT Assistant.app"
    echo "- The disk image in: dist/ChatGPT Assistant.dmg"
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Double-click 'ChatGPT Assistant.dmg'"
    echo "2. Drag the app to your Applications folder"
    echo "3. Right-click the app and choose 'Open'"
}

# Run the build process
main

# Keep terminal window open if there were any errors
read -p "Press Enter to exit..."
