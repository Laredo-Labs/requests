#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Packaging ChatGPT Assistant for macOS${NC}"
echo "========================================="

# Check for PyInstaller
if ! python3 -c "import PyInstaller" &> /dev/null; then
    echo -e "${RED}PyInstaller not found. Installing...${NC}"
    pip3 install pyinstaller
fi

# Create clean build directory
echo -e "${BLUE}Creating clean build environment...${NC}"
rm -rf dist build
mkdir -p build

# Create PyInstaller spec file
cat > build/ChatGPT_Assistant.spec << EOF
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(['chatgpt_app.py'],
             pathex=['.'],
             binaries=[],
             datas=[('icon.icns', '.'), ('version.txt', '.')],
             hiddenimports=['keyring.backends.macOS'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='ChatGPT Assistant',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=False,
          icon='icon.icns')

coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               upx_exclude=[],
               name='ChatGPT Assistant')

app = BUNDLE(coll,
            name='ChatGPT Assistant.app',
            icon='icon.icns',
            bundle_identifier='com.chatgpt.assistant',
            info_plist={
                'LSMinimumSystemVersion': '10.13',
                'NSHighResolutionCapable': True,
                'CFBundleShortVersionString': '1.0.0',
                'CFBundleVersion': '1',
                'NSRequiresAquaSystemAppearance': False,
                'CFBundleDisplayName': 'ChatGPT Assistant',
                'CFBundleName': 'ChatGPT Assistant',
                'CFBundleExecutable': 'ChatGPT Assistant',
                'CFBundleIconFile': 'icon.icns',
                'CFBundleIdentifier': 'com.chatgpt.assistant',
                'CFBundlePackageType': 'APPL',
                'LSApplicationCategoryType': 'public.app-category.productivity',
            })
EOF

# Create version file
echo "1.0.0" > version.txt

# Run PyInstaller
echo -e "${BLUE}Building application bundle...${NC}"
python3 -m PyInstaller build/ChatGPT_Assistant.spec --clean --noconfirm

# Check if build was successful
if [ ! -d "dist/ChatGPT Assistant.app" ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

# Create disk image
echo -e "${BLUE}Creating disk image...${NC}"
mkdir -p build/dmg
cp -R "dist/ChatGPT Assistant.app" build/dmg/
create-dmg \
    --volname "ChatGPT Assistant" \
    --volicon "icon.icns" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "ChatGPT Assistant.app" 200 190 \
    --hide-extension "ChatGPT Assistant.app" \
    --app-drop-link 600 185 \
    "dist/ChatGPT Assistant.dmg" \
    "build/dmg/" || {
        echo -e "${RED}Failed to create DMG${NC}"
        echo -e "${BLUE}Application bundle is still available at: dist/ChatGPT Assistant.app${NC}"
    }

echo -e "${GREEN}Build complete!${NC}"
echo -e "You can find the application at: ${BLUE}dist/ChatGPT Assistant.app${NC}"
if [ -f "dist/ChatGPT Assistant.dmg" ]; then
    echo -e "Disk image created at: ${BLUE}dist/ChatGPT Assistant.dmg${NC}"
fi

echo -e "\nTo install:"
echo "1. Open the disk image"
echo "2. Drag 'ChatGPT Assistant' to your Applications folder"
echo "3. Double-click to launch"
echo -e "\nFirst-time launch: Right-click > Open to bypass Gatekeeper"
