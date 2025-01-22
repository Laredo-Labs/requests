#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}ChatGPT Assistant Installer${NC}"
echo "==========================="

# Check if running with sudo/root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do not run this installer with sudo/root privileges${NC}"
    exit 1
fi

# Define paths
APP_NAME="ChatGPT Assistant.app"
SOURCE_APP="dist/$APP_NAME"
APPLICATIONS_DIR="$HOME/Applications"
SYSTEM_APPLICATIONS="/Applications"

# Check if the app exists
if [ ! -d "$SOURCE_APP" ]; then
    echo -e "${RED}Error: Application bundle not found!${NC}"
    echo "Please run package_mac_app.sh first to build the application."
    exit 1
fi

# Ask user where to install
echo -e "\nWhere would you like to install ChatGPT Assistant?"
echo "1) User Applications folder ($APPLICATIONS_DIR)"
echo "2) System Applications folder ($SYSTEM_APPLICATIONS) (requires admin password)"
read -p "Choose (1/2) [default: 1]: " choice

case $choice in
    2)
        INSTALL_DIR="$SYSTEM_APPLICATIONS"
        USE_SUDO=true
        ;;
    *)
        INSTALL_DIR="$APPLICATIONS_DIR"
        USE_SUDO=false
        # Create User Applications directory if it doesn't exist
        mkdir -p "$APPLICATIONS_DIR"
        ;;
esac

# Remove existing installation if present
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
    echo -e "${YELLOW}Removing previous installation...${NC}"
    if [ "$USE_SUDO" = true ]; then
        sudo rm -rf "$INSTALL_DIR/$APP_NAME"
    else
        rm -rf "$INSTALL_DIR/$APP_NAME"
    fi
fi

# Copy application bundle
echo -e "${BLUE}Installing ChatGPT Assistant...${NC}"
if [ "$USE_SUDO" = true ]; then
    sudo cp -R "$SOURCE_APP" "$INSTALL_DIR/"
else
    cp -R "$SOURCE_APP" "$INSTALL_DIR/"
fi

# Verify installation
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
    echo -e "${GREEN}Installation successful!${NC}"
    echo
    echo "To launch ChatGPT Assistant:"
    echo "1. Open Finder"
    echo "2. Go to the Applications folder"
    echo "3. Find 'ChatGPT Assistant'"
    echo
    echo "First time launch:"
    echo "1. Right-click 'ChatGPT Assistant'"
    echo "2. Choose 'Open'"
    echo "3. Click 'Open' in the security dialog"
    echo
    echo -e "${YELLOW}Tip: Drag the app from Applications to your Dock for easy access!${NC}"
    
    # Offer to add to Dock
    read -p "Would you like to add ChatGPT Assistant to your Dock? (y/n) [default: y]: " add_dock
    case $add_dock in
        [Nn]*)
            echo "Skipping Dock addition"
            ;;
        *)
            # Add to Dock using macOS defaults command
            defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$INSTALL_DIR/$APP_NAME</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
            killall Dock
            echo -e "${GREEN}Added to Dock!${NC}"
            ;;
    esac
else
    echo -e "${RED}Installation failed!${NC}"
    exit 1
fi
