# Git Safety Guide: Handling Accidental Pushes

## 🚨 Immediate Actions for Accidental Push

### Remove the Branch
```bash
# Delete branch from remote (e.g., GitHub)
git push origin --delete branch_name

# Delete branch locally
git branch -d branch_name
```

### If Sensitive Data Was Exposed
1. **Immediately rotate any credentials**
   - Change API keys
   - Reset passwords
   - Update tokens

2. **Contact repository administrators**
   - Inform them of the accidental push
   - Request review of access logs

## 🔒 Prevention Tips

### 1. Use .gitignore
```bash
# Example .gitignore entries
.env
*.key
config/secrets.yml
credentials/
```

### 2. Git Hooks
Create a pre-commit hook to check for sensitive patterns:
```bash
#!/bin/bash
if git diff --cached | grep -i "api_key\|password\|secret"
then
    echo "WARNING: Possible sensitive data detected"
    exit 1
fi
```

### 3. Safe Branch Management
```bash
# Always create new branches from main/master
git checkout main
git pull
git checkout -b feature/safe-branch

# Check what will be pushed
git diff origin/main..HEAD
```

## 🛡️ Best Practices

1. **Never Store Secrets in Code**
   - Use environment variables
   - Use secret management systems
   - Use credential managers

2. **Review Before Push**
   ```bash
   # Check changes to be pushed
   git status
   git diff
   ```

3. **Use Protected Branches**
   - Set up branch protection rules
   - Require pull request reviews
   - Enable required status checks

## 🆘 Emergency Response

If sensitive data was pushed:

1. **Document the Incident**
   - When it happened
   - What was exposed
   - Who has access

2. **Clean Repository History**
   ```bash
   # Using BFG Repo Cleaner
   bfg --replace-text sensitive-strings.txt
   ```

3. **Force Push Clean History**
   ```bash
   git push --force origin main
   ```
   ⚠️ Use force push with extreme caution!

## 🔍 Verify Access

1. Check repository settings:
   - Go to repository settings
   - Review collaborators
   - Check branch protection rules

2. Audit access logs:
   - Review recent clones
   - Check access patterns
   - Monitor for unusual activity

## 📝 Future Prevention

1. **Set Up Git Configurations**
   ```bash
   # Global gitignore
   git config --global core.excludesfile ~/.gitignore_global
   ```

2. **Use Git LFS for Large Files**
   ```bash
   git lfs install
   git lfs track "*.zip"
   ```

3. **Regular Security Audits**
   - Review repository settings monthly
   - Update access permissions regularly
   - Keep documentation current

## 🎯 Quick Reference

### Common Commands
```bash
# Check current branches
git branch -a

# View remote URLs
git remote -v

# Remove remote tracking
git branch -dr origin/branch_name

# Clean up references
git fetch --prune
```

### GitHub GUI Steps
1. Navigate to repository
2. Click "Settings"
3. Select "Branches"
4. Find the branch
5. Click delete (trash can icon)

Remember: Prevention is better than cure. Always review changes before pushing!
