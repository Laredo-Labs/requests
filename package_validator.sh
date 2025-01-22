#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check package versions
check_version() {
    local pkg="$1"
    local min_version="$2"
    local installed_version

    # Get installed version
    installed_version=$(pip show "$pkg" 2>/dev/null | grep Version | cut -d' ' -f2)
    
    if [ -z "$installed_version" ]; then
        echo -e "${RED}✗ $pkg not installed${NC}"
        return 1
    fi
    
    # Compare versions
    if python3 -c "from packaging import version; exit(0 if version.parse('$installed_version') >= version.parse('$min_version') else 1)" 2>/dev/null; then
        echo -e "${GREEN}✓ $pkg $installed_version${NC}"
        return 0
    else
        echo -e "${YELLOW}! $pkg $installed_version (min: $min_version)${NC}"
        return 1
    fi
}

# Function to validate all required packages
validate_packages() {
    local requirements_file="$1"
    local has_error=0
    
    echo -e "${BLUE}Validating Python packages...${NC}"
    
    # Check if requirements file exists
    if [ ! -f "$requirements_file" ]; then
        echo -e "${RED}Error: $requirements_file not found${NC}"
        exit 1
    }
    
    # Read requirements file and check each package
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi
        
        # Extract package name and version
        if [[ "$line" =~ ([a-zA-Z0-9_-]+)([><=]=?)([0-9.]+) ]]; then
            pkg="${BASH_REMATCH[1]}"
            op="${BASH_REMATCH[2]}"
            ver="${BASH_REMATCH[3]}"
            
            if ! check_version "$pkg" "$ver"; then
                has_error=1
            fi
        elif [[ "$line" =~ ^[a-zA-Z0-9_-]+ ]]; then
            # Package without version requirement
            pkg="${BASH_REMATCH[0]}"
            if ! check_version "$pkg" "0"; then
                has_error=1
            fi
        fi
    done < "$requirements_file"
    
    if [ $has_error -eq 1 ]; then
        echo -e "\n${YELLOW}Some packages need updating. Running pip install...${NC}"
        if pip install -r "$requirements_file" --upgrade; then
            echo -e "${GREEN}All packages updated successfully${NC}"
            return 0
        else
            echo -e "${RED}Failed to update packages${NC}"
            return 1
        fi
    else
        echo -e "\n${GREEN}All packages are up to date${NC}"
        return 0
    fi
}

# Provide usage when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <requirements_file>"
        echo "Example: $0 requirements.txt"
        exit 1
    fi
    
    validate_packages "$1"
fi
