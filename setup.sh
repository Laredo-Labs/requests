#!/bin/bash

# Print colorful messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print step messages
print_step() {
    echo -e "${BLUE}Step: $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}Success: $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Welcome message
echo "╔════════════════════════════════════════╗"
echo "║     ChatGPT Mac Assistant Setup        ║"
echo "╚════════════════════════════════════════╝"
echo

# Check if Python 3.8 or higher is installed
print_step "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3.8 or higher from python.org"
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
if (( $(echo "$PYTHON_VERSION < 3.8" | bc -l) )); then
    print_error "Python 3.8 or higher is required. You have Python $PYTHON_VERSION"
fi
print_success "Found Python $PYTHON_VERSION"

# Create virtual environment if it doesn't exist
print_step "Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv || print_error "Failed to create virtual environment"
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi

# Activate virtual environment
print_step "Activating virtual environment..."
source venv/bin/activate || print_error "Failed to activate virtual environment"
print_success "Virtual environment activated"

# Install requirements
print_step "Installing required packages..."
pip install -r requirements.txt || print_error "Failed to install dependencies"
print_success "All packages installed successfully"

# Set up API key
print_step "Setting up OpenAI API key..."
if [ ! -f ".env" ]; then
    echo
    echo "Please enter your OpenAI API key (starts with 'sk-'):"
    read -r api_key
    
    if [[ ! $api_key =~ ^sk- ]]; then
        print_error "Invalid API key format. The key should start with 'sk-'"
    fi
    
    echo "OPENAI_API_KEY=$api_key" > .env
    print_success "API key saved successfully"
else
    print_success "API key configuration already exists"
fi

# Make scripts executable
chmod +x run_app.sh 2>/dev/null || true
chmod +x ChatGPT_Assistant.command 2>/dev/null || true

# Create Applications folder shortcut
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_step "Setting up easy access..."
    
    # Create Applications folder shortcut if it doesn't exist
    if [ ! -e "$HOME/Applications/ChatGPT Assistant.app" ]; then
        if cp -R ChatGPT_Assistant.command "$HOME/Applications/ChatGPT Assistant" 2>/dev/null; then
            print_success "Created Applications folder shortcut"
        else
            print_warning "Could not create Applications shortcut (this is optional)"
        fi
    fi
fi

# Final success message
echo
echo "╔════════════════════════════════════════╗"
echo "║        Setup Complete! 🎉              ║"
echo "╚════════════════════════════════════════╝"
echo
echo "To start the application:"
echo "  Option 1: Double-click 'ChatGPT_Assistant.command' in Finder"
echo "  Option 2: Type './run_app.sh' in Terminal"
echo
print_step "First time launching? Right-click 'ChatGPT_Assistant.command' → Open → Open"
echo
