#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo -e "${BLUE}Making scripts executable...${NC}"

# List of files to make executable
FILES=(
    "build_app.command"
    "ChatGPT_Assistant.command"
    "simple_build.command"
    "test_app.command"
    "setup.sh"
    "run_app.sh"
    "build_release.sh"
    "package_mac_app.sh"
    "create_mac_app.sh"
    "make_executable.command"
)

# Make each file executable
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        chmod +x "$file"
        echo -e "${GREEN}✓ Made executable: $file${NC}"
    else
        echo -e "${RED}✗ File not found: $file${NC}"
    fi
done

echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run ./build_app.command"
echo "2. Wait for build to complete"
echo "3. Check dist folder for the app"
echo
echo -e "${GREEN}You can now close this window${NC}"

# Keep window open if there were errors
read -p "Press Enter to exit..."
