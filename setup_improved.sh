#!/bin/bash

# Print colorful messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_step() { echo -e "${BLUE}Step: $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}Error: $1${NC}"; exit 1; }
print_warning() { echo -e "${YELLOW}Warning: $1${NC}"; }

# Backup existing configuration
backup_config() {
    print_step "Backing up existing configuration..."
    
    BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # List of files to backup
    BACKUP_FILES=(".env" "venv" "ChatGPT_Assistant.command" "run_app.sh")
    
    for file in "${BACKUP_FILES[@]}"; do
        if [ -e "$file" ]; then
            cp -R "$file" "$BACKUP_DIR/" 2>/dev/null
            print_success "Backed up: $file"
        fi
    done
    
    # Create backup manifest
    echo "Backup created on $(date)" > "$BACKUP_DIR/manifest.txt"
    echo "Python version: $(python3 --version)" >> "$BACKUP_DIR/manifest.txt"
    echo "macOS version: $(sw_vers -productVersion)" >> "$BACKUP_DIR/manifest.txt"
    
    print_success "Configuration backed up to: $BACKUP_DIR"
    return 0
}

# Restore from backup
restore_config() {
    local backup_dir="$1"
    print_step "Restoring configuration from backup..."
    
    if [ ! -d "$backup_dir" ]; then
        print_error "Backup directory not found: $backup_dir"
    fi
    
    # Check manifest
    if [ ! -f "$backup_dir/manifest.txt" ]; then
        print_error "Invalid backup: manifest.txt not found"
    fi
    
    # Restore files
    for file in "$backup_dir"/*; do
        base_name=$(basename "$file")
        if [ "$base_name" != "manifest.txt" ]; then
            cp -R "$file" "./" 2>/dev/null
            if [ $? -eq 0 ]; then
                print_success "Restored: $base_name"
            else
                print_warning "Failed to restore: $base_name"
            fi
        fi
    done
    
    print_success "Configuration restored from: $backup_dir"
    return 0
}

# Show fancy header
show_header() {
    clear
    echo "╔════════════════════════════════════════════════╗"
    echo "║        ChatGPT Assistant Setup Wizard          ║"
    echo "╚════════════════════════════════════════════════╝"
    echo
}

# Check system requirements
check_system() {
    print_step "Checking system requirements..."
    
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This setup is for macOS only"
    fi
    
    # Check Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        print_warning "Xcode Command Line Tools not found"
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Please run this setup again after the installation completes"
        exit 0
    fi
    
    print_success "System requirements met"
}

# Check and install Python
check_python() {
    print_step "Checking Python installation..."
    
    if ! command -v python3 &>/dev/null; then
        print_error "Python 3 not found. Please install from python.org"
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if (( $(echo "$PYTHON_VERSION < 3.8" | bc -l) )); then
        print_error "Python 3.8 or higher required. Found version $PYTHON_VERSION"
    fi
    
    print_success "Found Python $PYTHON_VERSION"
}

# Set up virtual environment
setup_venv() {
    print_step "Setting up Python virtual environment..."
    
    if [ -d "venv" ]; then
        print_warning "Existing virtual environment found"
        read -p "Would you like to recreate it? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf venv
            print_success "Old virtual environment removed"
        fi
    fi
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv || print_error "Failed to create virtual environment"
        print_success "Virtual environment created"
    fi
    
    source venv/bin/activate || print_error "Failed to activate virtual environment"
    print_success "Virtual environment activated"
    
    # Upgrade pip
    python3 -m pip install --upgrade pip || print_error "Failed to upgrade pip"
}

# Install dependencies
install_dependencies() {
    print_step "Installing required packages..."
    
    # Check if requirements.txt exists
    if [ ! -f "requirements.txt" ]; then
        print_error "requirements.txt not found"
    fi
    
    # Make package validator executable
    chmod +x package_validator.sh || print_error "Failed to make package validator executable"
    
    # First installation of base requirements
    print_warning "Installing base requirements..."
    pip install packaging || print_error "Failed to install packaging module"
    
    # Validate and install packages
    ./package_validator.sh requirements.txt || print_error "Failed to install/validate packages"
    print_success "All packages installed and validated successfully"
    
    # Verify critical packages
    print_step "Verifying critical dependencies..."
    
    CRITICAL_PKGS=("openai" "PyQt6" "keyring")
    for pkg in "${CRITICAL_PKGS[@]}"; do
        if ! pip show "$pkg" &>/dev/null; then
            print_error "Critical package '$pkg' not installed correctly"
        fi
    done
    
    print_success "Critical package verification completed"
}

# Configure API key
setup_api_key() {
    print_step "Setting up OpenAI API key..."
    
    if [ -f ".env" ]; then
        print_warning "API key configuration already exists"
        read -p "Would you like to update it? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_success "Using existing API key"
            return
        fi
    fi
    
    echo
    echo "Please enter your OpenAI API key (starts with 'sk-'):"
    read -rs api_key  # -s flag hides the input
    echo
    
    if [[ ! $api_key =~ ^sk- ]]; then
        print_error "Invalid API key format. Key must start with 'sk-'"
    fi
    
    echo "OPENAI_API_KEY=$api_key" > .env
    chmod 600 .env  # Secure file permissions
    print_success "API key saved securely"
}

# Prepare application files
prepare_app() {
    print_step "Preparing application files..."
    
    # Make scripts executable
    chmod +x run_app.sh ChatGPT_Assistant.command || print_warning "Failed to make scripts executable"
    
    # Create Applications folder shortcut
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ ! -e "$HOME/Applications/ChatGPT Assistant" ]; then
            ln -s "$(pwd)/ChatGPT_Assistant.command" "$HOME/Applications/ChatGPT Assistant"
            print_success "Created Applications folder shortcut"
        fi
    fi
}

# Cleanup function
cleanup() {
    print_step "Cleaning up..."
    
    if [ -n "$1" ]; then
        print_warning "Setup failed: $1"
    fi
    
    # Deactivate virtual environment if active
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate 2>/dev/null
    fi
    
    # Remove incomplete virtual environment
    if [ "$1" ] && [ -d "venv" ]; then
        print_warning "Removing incomplete virtual environment..."
        rm -rf venv
    fi
    
    # Remove failed package validator if exists
    if [ "$1" ] && [ -f "package_validator.sh" ]; then
        if [ ! -x "package_validator.sh" ]; then
            rm -f package_validator.sh
        fi
    fi
    
    # Print error message if provided
    if [ -n "$1" ]; then
        print_error "Setup failed: $1"
    fi
}

# Set up trap for cleanup
trap 'cleanup "Interrupted by user"' INT TERM

# Process command line arguments
process_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restore)
                if [ -z "$2" ]; then
                    print_error "Backup directory not specified"
                fi
                restore_config "$2"
                exit 0
                ;;
            --backup-only)
                backup_config
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                ;;
        esac
        shift
    done
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --restore <dir>    Restore configuration from backup directory"
    echo "  --backup-only      Create backup of current configuration and exit"
    echo "  --help            Show this help message"
    echo
    echo "Running without options performs a normal setup."
}

# Main setup process
main() {
    show_header
    
    # Process any command line arguments
    process_args "$@"
    
    # Check for existing configuration
    if [ -f ".env" ] || [ -d "venv" ]; then
        print_warning "Existing configuration detected"
        read -p "Would you like to backup before proceeding? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            backup_config
        fi
    fi
    
    # Create temporary directory for setup
    TEMP_DIR=$(mktemp -d)
    print_step "Created temporary directory: $TEMP_DIR"
    
    # Copy package validator to temp directory
    cp package_validator.sh "$TEMP_DIR/" || cleanup "Failed to copy package validator"
    
    # Main setup steps
    check_system || cleanup "System check failed"
    check_python || cleanup "Python check failed"
    setup_venv || cleanup "Virtual environment setup failed"
    install_dependencies || cleanup "Package installation failed"
    setup_api_key || cleanup "API key setup failed"
    prepare_app || cleanup "Application preparation failed"
    
    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
    
    # Show completion message
    echo
    echo "╔════════════════════════════════════════════════╗"
    echo "║           Setup Complete! 🎉                   ║"
    echo "╚════════════════════════════════════════════════╝"
    echo
    echo "To start ChatGPT Assistant:"
    echo "1. Double-click 'ChatGPT Assistant' in Applications"
    echo "2. Or double-click 'ChatGPT_Assistant.command' in Finder"
    echo "3. Or run './run_app.sh' in Terminal"
    echo
    print_warning "First time launching? Right-click → Open → Open"
    echo
}

# Run setup
main "$@"
