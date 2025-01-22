# Troubleshooting Guide

## 🚫 Common Problems & Solutions

### "Cannot be opened because it is from an unidentified developer"
1. Right-click the file
2. Choose "Open"
3. Click "Open" in the popup
   - You only need to do this once

### Python Not Found
1. Download Python from python.org
2. Double-click the downloaded file
3. Follow the installer
4. Try the build again

### Permission Denied
If you see "Permission denied":
```bash
# Copy and paste these commands:
chmod +x build_app.command
chmod +x setup.sh
chmod +x run_app.sh
chmod +x package_mac_app.sh
```

### Build Fails
1. Clean up and try again:
```bash
rm -rf dist build
rm -rf venv
./build_app.command
```

2. If that doesn't work:
   - Close Terminal
   - Open new Terminal
   - Try again

### DMG Creation Fails
1. Make sure you have space on your Mac
2. Close all other apps
3. Try again:
```bash
./build_app.command
```

### API Key Problems
If the app won't accept your API key:
1. Check it starts with 'sk-'
2. Make sure you copied the whole key
3. Check your OpenAI account credit
4. Try updating the key in the app's settings

### App Won't Open
1. Move app to trash
2. Empty trash
3. Install again from DMG
4. Right-click → Open first time

## 🔍 Checking Your Build

### Is Python Installed?
```bash
python3 --version
# Should show 3.8 or higher
```

### Are Files Executable?
```bash
ls -l *.command *.sh
# Should show -rwxr-xr-x
```

### Is Build Complete?
Look in `dist` folder for:
- `ChatGPT Assistant.app`
- `ChatGPT Assistant.dmg`

## 🆘 If Nothing Works

### Start Fresh
1. Delete these folders if they exist:
   - `dist`
   - `build`
   - `venv`

2. Close Terminal

3. Download Python again:
   - Go to python.org
   - Download latest version
   - Install it

4. Try build again:
   ```bash
   ./build_app.command
   ```

### Still Stuck?

1. Check your internet connection
2. Make sure you have:
   - At least 1GB free space
   - Python 3.8 or higher
   - macOS 10.13 or higher

3. Look for error messages:
   - Red text in Terminal
   - Write down the exact error
   - Search for the error online

4. Common fixes:
   - Restart your Mac
   - Update macOS
   - Clear Trash
   - Free up disk space

## ✅ Success Checklist

- [ ] Python installed correctly
- [ ] All files are executable
- [ ] Build completed without errors
- [ ] DMG file created
- [ ] App opens from Applications
- [ ] API key accepted
- [ ] Chat works

Remember: If you're stuck, start fresh and follow BUILD_STEPS.md one step at a time!
