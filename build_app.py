import PyInstaller.__main__
import sys
import os

def build_app():
    # Get the directory containing this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Define the path to the main script
    main_script = os.path.join(script_dir, 'chatgpt_app.py')
    
    # Define PyInstaller arguments
    args = [
        main_script,
        '--name=ChatGPT Assistant',
        '--onefile',
        '--windowed',
        '--icon=None',  # You can add an icon file later
        '--add-data=.env:.',
        '--hidden-import=PyQt6',
        '--hidden-import=openai',
        '--hidden-import=python-dotenv',
        '--clean',
        '--noconfirm',
        # Add macOS specific options
        '--target-architecture=universal2',  # Build for both Intel and Apple Silicon
        '--codesign-identity=None',  # Sign with default keychain identity
    ]
    
    # Run PyInstaller
    PyInstaller.__main__.run(args)

if __name__ == '__main__':
    try:
        build_app()
        print("Application built successfully!")
        print("The executable can be found in the 'dist' directory.")
    except Exception as e:
        print(f"Error building application: {str(e)}")
        sys.exit(1)
