#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_exit="$3"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    # Run the test command
    eval "$test_cmd" > /dev/null 2>&1
    local exit_code=$?
    
    # Check result
    if [ $exit_code -eq $expected_exit ]; then
        echo -e "${GREEN}✓ Passed${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ Failed (expected: $expected_exit, got: $exit_code)${NC}"
        ((TESTS_FAILED++))
    fi
}

# Function to clean test environment
clean_env() {
    rm -rf venv .env backup_* temp_*
}

# Start testing
echo "🧪 Starting setup script tests"
echo "=============================="

# Backup current environment if it exists
if [ -f ".env" ] || [ -d "venv" ]; then
    echo -e "${YELLOW}Backing up current environment...${NC}"
    ./setup_improved.sh --backup-only
fi

# Clean environment
clean_env

# Test 1: Help command
run_test "Help command" \
    "./setup_improved.sh --help" 0

# Test 2: Invalid option
run_test "Invalid option" \
    "./setup_improved.sh --invalid-option" 1

# Test 3: Backup with no existing config
run_test "Backup with no config" \
    "./setup_improved.sh --backup-only" 0

# Test 4: Restore with invalid backup
run_test "Restore invalid backup" \
    "./setup_improved.sh --restore invalid_backup" 1

# Test 5: Create mock environment and test backup
mkdir -p venv
echo "OPENAI_API_KEY=sk-test" > .env
run_test "Backup existing config" \
    "./setup_improved.sh --backup-only" 0

# Test 6: Try to restore valid backup
LATEST_BACKUP=$(ls -td backup_* | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    run_test "Restore valid backup" \
        "./setup_improved.sh --restore $LATEST_BACKUP" 0
fi

# Test 7: Python version check
run_test "Python version check" \
    "python3 -c 'import sys; exit(0 if sys.version_info >= (3,8) else 1)'" 0

# Test 8: Package validator
run_test "Package validator script" \
    "./package_validator.sh requirements.txt" 0

# Test 9: Cleanup after interrupted setup
./setup_improved.sh &
sleep 1
pkill -INT -f "setup_improved.sh"
run_test "Cleanup after interrupt" \
    "[ ! -d venv ] && [ ! -f .env ]" 0

# Test 10: Full installation
run_test "Full installation" \
    "./setup_improved.sh" 0

# Print results
echo "=============================="
echo -e "${BLUE}Test Results:${NC}"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "=============================="

# Restore original environment if backup exists
ORIGINAL_BACKUP=$(ls -td backup_* | tail -1)
if [ -n "$ORIGINAL_BACKUP" ]; then
    echo -e "${YELLOW}Restoring original environment...${NC}"
    ./setup_improved.sh --restore "$ORIGINAL_BACKUP"
fi

# Clean up test backups
find . -name "backup_*" -type d -exec rm -rf {} +

# Exit with status based on test results
[ $TESTS_FAILED -eq 0 ]
