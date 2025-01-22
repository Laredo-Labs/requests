#!/bin/bash

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function for colorful output
print_blue() { echo -e "\033[0;34m$1\033[0m"; }
print_green() { echo -e "\033[0;32m$1\033[0m"; }
print_red() { echo -e "\033[0;31m$1\033[0m"; }

# Clear terminal and show welcome message
clear
echo "==============================================="
print_blue "        ChatGPT Assistant Launcher"
echo "==============================================="
echo

# Change to application directory
cd "$DIR"

# Check if setup has been completed
if [ ! -f ".env" ] || [ ! -d "venv" ]; then
    print_red "First-time setup required!"
    echo
    print_blue "Running setup script..."
    echo
    
    # Make setup script executable if it isn't already
    chmod +x setup.sh
    
    # Run setup
    ./setup.sh
    
    if [ $? -ne 0 ]; then
        print_red "Setup failed. Please try again."
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

# Make run script executable if it isn't already
chmod +x run_app.sh

# Run the application
print_green "Starting ChatGPT Assistant..."
echo
./run_app.sh

# Keep terminal window open if there was an error
if [ $? -ne 0 ]; then
    print_red "Application exited with an error."
    read -p "Press Enter to close this window..."
fi
