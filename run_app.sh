#!/bin/bash

# Print colorful messages
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_error() { echo -e "${RED}Error: $1${NC}"; exit 1; }
print_info() { echo -e "${BLUE}Info: $1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}Warning: $1${NC}"; }

# Welcome message
echo "╔════════════════════════════════════════╗"
echo "║      ChatGPT Mac Assistant             ║"
echo "╚════════════════════════════════════════╝"

# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if setup has been run
if [ ! -d "$DIR/venv" ]; then
    print_error "Virtual environment not found.\nPlease run './setup.sh' first to set up the application."
fi

# Check if we're in the correct directory
cd "$DIR" || print_error "Failed to change to application directory."

# Check if required files exist
if [ ! -f "chatgpt_app.py" ]; then
    print_error "Application files not found.\nPlease make sure all files are in place and try again."
fi

# Check if API key is configured
if [ ! -f ".env" ]; then
    print_error "API key not configured.\nPlease run './setup.sh' to configure your OpenAI API key."
fi

# Activate virtual environment
print_info "Starting up..."
source "$DIR/venv/bin/activate" || print_error "Failed to activate virtual environment"

# Check internet connection
print_info "Checking internet connection..."
if ! ping -c 1 api.openai.com &> /dev/null; then
    print_warning "Could not reach OpenAI servers. Check your internet connection."
fi

# Run the application
print_success "\nLaunching ChatGPT Assistant...\n"
python chatgpt_app.py

# Handle application exit
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    print_error "Application exited with error code $EXIT_CODE"
fi

# Deactivate virtual environment
deactivate 2>/dev/null

print_success "\nThank you for using ChatGPT Assistant!\n"
