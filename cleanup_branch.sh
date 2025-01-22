#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print usage
print_usage() {
    echo "Usage: $0 <branch_name>"
    echo "Safely removes a branch from both local and remote repositories."
}

# Check if branch name is provided
if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi

BRANCH_NAME=$1

echo -e "${BLUE}Starting cleanup process for branch: ${YELLOW}$BRANCH_NAME${NC}"
echo "================================================"

# Confirm action
echo -e "${RED}WARNING: This will delete the branch '$BRANCH_NAME' from both local and remote repositories.${NC}"
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Operation cancelled.${NC}"
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository!${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if trying to delete current branch
if [ "$CURRENT_BRANCH" == "$BRANCH_NAME" ]; then
    echo -e "${RED}Error: Cannot delete the current branch.${NC}"
    echo -e "Please checkout a different branch first:"
    echo -e "${BLUE}git checkout main${NC}"
    exit 1
fi

echo -e "\n${BLUE}Step 1: Checking if branch exists...${NC}"

# Check if branch exists locally
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo -e "${GREEN}✓ Branch exists locally${NC}"
    LOCAL_EXISTS=true
else
    echo -e "${YELLOW}! Branch does not exist locally${NC}"
    LOCAL_EXISTS=false
fi

# Check if branch exists in remote
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    echo -e "${GREEN}✓ Branch exists in remote${NC}"
    REMOTE_EXISTS=true
else
    echo -e "${YELLOW}! Branch does not exist in remote${NC}"
    REMOTE_EXISTS=false
fi

if [ "$LOCAL_EXISTS" = false ] && [ "$REMOTE_EXISTS" = false ]; then
    echo -e "${RED}Error: Branch '$BRANCH_NAME' not found in local or remote repository${NC}"
    exit 1
fi

# Delete from remote
if [ "$REMOTE_EXISTS" = true ]; then
    echo -e "\n${BLUE}Step 2: Deleting remote branch...${NC}"
    if git push origin --delete "$BRANCH_NAME"; then
        echo -e "${GREEN}✓ Remote branch deleted successfully${NC}"
    else
        echo -e "${RED}Failed to delete remote branch${NC}"
        exit 1
    fi
fi

# Delete locally
if [ "$LOCAL_EXISTS" = true ]; then
    echo -e "\n${BLUE}Step 3: Deleting local branch...${NC}"
    if git branch -D "$BRANCH_NAME"; then
        echo -e "${GREEN}✓ Local branch deleted successfully${NC}"
    else
        echo -e "${RED}Failed to delete local branch${NC}"
        exit 1
    fi
fi

# Clean up
echo -e "\n${BLUE}Step 4: Cleaning up references...${NC}"
git fetch --prune
echo -e "${GREEN}✓ References cleaned${NC}"

echo -e "\n${GREEN}Branch cleanup completed successfully!${NC}"
echo -e "\nNext steps:"
echo -e "1. Verify the branch is gone:"
echo -e "   ${BLUE}git branch -a${NC}"
echo -e "2. If needed, update any pull requests targeting this branch"
echo -e "3. Inform your team about the branch removal"
