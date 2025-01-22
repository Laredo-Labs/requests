#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error handling
set -e
trap 'catch $? $LINENO' ERR

catch() {
    echo -e "${RED}Error $1 occurred on line $2${NC}"
    exit 1
}

# Function to print status messages
print_status() {
    echo -e "${BLUE}=> $1${NC}"
}

# Check for required commands
check_requirements() {
    print_status "Checking requirements..."
    
    REQUIRED_CMDS=("python3" "pip3" "iconutil")
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}Error: Required command '$cmd' not found${NC}"
            exit 1
        fi
    done
}

# Create application icon
create_icon() {
    if [ -f "create_icon.sh" ]; then
        print_status "Creating application icon..."
        chmod +x create_icon.sh
        ./create_icon.sh
    else
        echo -e "${YELLOW}Warning: create_icon.sh not found, using default icon${NC}"
    fi
}

echo -e "${BLUE}Creating ChatGPT Assistant for macOS${NC}"
echo "================================================"

# Check requirements
check_requirements

# Create icon
create_icon

# Version information
VERSION="1.0.0"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

# Application structure
APP_NAME="ChatGPT Assistant.app"
CONTENTS_DIR="$APP_NAME/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SCRIPTS_DIR="$CONTENTS_DIR/Scripts"

print_status "Creating application structure..."
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$SCRIPTS_DIR"

# Copy icon
if [ -f "icon.icns" ]; then
    cp icon.icns "$RESOURCES_DIR/"
else
    echo -e "${YELLOW}Warning: No custom icon found${NC}"
fi

# Copy application files
print_status "Copying application files..."
cp chatgpt_app.py config_manager.py requirements.txt "$RESOURCES_DIR/"

# Create virtual environment in the app bundle
print_status "Setting up Python environment..."
python3 -m venv "$RESOURCES_DIR/venv"
source "$RESOURCES_DIR/venv/bin/activate"
pip3 install --no-cache-dir -r requirements.txt
deactivate

# Create Info.plist with more detailed metadata
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>icon</string>
    <key>CFBundleIdentifier</key>
    <string>com.chatgpt.assistant</string>
    <key>CFBundleName</key>
    <string>ChatGPT Assistant</string>
    <key>CFBundleDisplayName</key>
    <string>ChatGPT Assistant</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>LSArchitecturePriority</key>
    <array>
        <string>arm64</string>
        <string>x86_64</string>
    </array>
</dict>
</plist>
EOF

# Create the launcher script with improved error handling
cat > "$MACOS_DIR/launcher" << 'EOF'
#!/bin/bash

# Error handling
set -e
trap 'handle_error $? $LINENO' ERR

handle_error() {
    osascript -e "display alert \"Error\" message \"An error occurred while starting ChatGPT Assistant. Please try again.\n\nError code: $1\nLine: $2\""
    exit 1
}

# Get the bundle's root directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONTENTS="$DIR/.."
RESOURCES="$CONTENTS/Resources"

# Activate virtual environment
source "$RESOURCES/venv/bin/activate"

# Set Python path to find modules
export PYTHONPATH="$RESOURCES:$PYTHONPATH"

# Change to Resources directory
cd "$RESOURCES"

# Launch the application with error handling
python3 chatgpt_app.py || handle_error $? $LINENO

# Deactivate virtual environment
deactivate
EOF

# Make launcher executable
chmod +x "$MACOS_DIR/launcher"

# Create version file for update checking
echo "${VERSION}" > "$RESOURCES_DIR/version.txt"

print_status "Finalizing application bundle..."

# Set proper permissions
chmod -R 755 "$APP_NAME"

# Success message
echo -e "${GREEN}Successfully created ChatGPT Assistant.app${NC}"
echo -e "${BLUE}Version: ${VERSION}${NC}"
echo -e "${BLUE}Build: ${BUILD_NUMBER}${NC}"
echo
echo "You can now:"
echo "1. Move ChatGPT Assistant.app to your Applications folder"
echo "2. Launch it from Spotlight or Finder"
echo "3. Add it to your Dock for easy access"

# Create launcher script
cat > "$MACOS_DIR/launcher" << 'EOF'
#!/bin/bash

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_ROOT="$DIR/../.."
CONTENTS="$DIR/.."

# Change to the application directory
cd "$APP_ROOT"

# Ensure Python environment exists
if [ ! -d "venv" ]; then
    echo "First-time setup required. This may take a minute..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Run setup script if API key not configured
    if [ ! -f ".env" ]; then
        python chatgpt_app.py --setup
    fi
else
    source venv/bin/activate
fi

# Launch the application
python chatgpt_app.py

# Deactivate virtual environment
deactivate
EOF

# Make launcher executable
chmod +x "$MACOS_DIR/launcher"

# Copy application files
cp chatgpt_app.py requirements.txt "$APP_NAME/"

echo -e "${GREEN}Application bundle created: $APP_NAME${NC}"
echo -e "${BLUE}You can now:${NC}"
echo "1. Move it to your Applications folder"
echo "2. Add it to your Dock"
echo "3. Double-click to launch"
