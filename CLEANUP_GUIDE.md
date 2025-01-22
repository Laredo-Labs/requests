# Branch Cleanup Tool Guide

## 🚀 Quick Start

1. Make the script executable:
   ```bash
   chmod +x cleanup_branch.sh
   ```

2. Run the script with the branch name:
   ```bash
   ./cleanup_branch.sh branch-to-delete
   ```

## ✨ Features

- Safe deletion of both local and remote branches
- Interactive confirmation before deletion
- Prevents accidental deletion of current branch
- Automatic cleanup of stale references
- Colored output for better visibility
- Clear error messages and next steps

## 🛡️ Safety Checks

The script performs several safety checks:
- Verifies you're in a git repository
- Checks if the branch exists locally and/or remotely
- Prevents deletion of currently checked-out branch
- Requires confirmation before deletion
- Reports success/failure of each step

## 📋 Examples

### Delete a feature branch
```bash
./cleanup_branch.sh feature/new-feature
```

### Delete a bugfix branch
```bash
./cleanup_branch.sh bugfix/issue-123
```

## ❌ Common Errors

1. "Not a git repository"
   - Make sure you're in your git project directory
   - Run: `cd your-project-directory`

2. "Cannot delete the current branch"
   - Switch to a different branch first
   - Run: `git checkout main`

3. "Branch not found"
   - Check if the branch name is correct
   - Run: `git branch -a` to list all branches

## 🔍 Verifying Deletion

After running the script, verify the branch is gone:
```bash
# List all branches
git branch -a

# Check remote branches
git ls-remote --heads origin
```

## 💡 Tips

1. Always ensure you're on the right branch before deletion:
   ```bash
   git checkout main
   ```

2. Keep your local repository in sync:
   ```bash
   git fetch --prune
   ```

3. If you need to recover a deleted branch, check the reflog:
   ```bash
   git reflog
   ```

## ⚠️ Important Notes

- Branch deletion is permanent for other users
- They will need to update their local repositories
- Inform your team when deleting shared branches
- Consider archiving important branches instead of deleting

## 🆘 Help

For additional help:
1. Read the full Git safety guide: `GIT_SAFETY.md`
2. Run the script without arguments for usage info
3. Contact your repository administrator

Remember: Always double-check the branch name before confirming deletion!
