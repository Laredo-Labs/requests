# ChatGPT Mac Assistant - Installation and Usage Instructions

## Prerequisites

- macOS operating system
- Python 3.8 or higher installed
- OpenAI API key (get one from https://platform.openai.com/api-keys)

### System Dependencies

On macOS:
```bash
brew install qt6
```

On Linux (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y python3-pyqt6 libgl1-mesa-glx
```

On Linux (Fedora/RHEL):
```bash
sudo dnf install python3-qt6 mesa-libGL
```

## Manual Installation Steps

1. **Create and activate a virtual environment**
```bash
python3 -m venv venv
source venv/bin/activate
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure your API key**
Create a file named `.env` in the project root and add your OpenAI API key:
```
OPENAI_API_KEY=your_api_key_here
```

## Running the Application

1. **Activate the virtual environment** (if not already activated):
```bash
source venv/bin/activate
```

2. **Start the application**:
```bash
python chatgpt_app.py
```

## Troubleshooting

### Common Issues

1. **API Key Issues**
- Ensure your OpenAI API key is correctly set in the `.env` file
- Check that the API key starts with 'sk-'
- Verify your API key is valid at https://platform.openai.com

2. **Dependencies Issues**
- If you encounter dependency errors, try:
```bash
pip install --upgrade -r requirements.txt
```

3. **Permission Issues**
- Make sure the setup and run scripts are executable:
```bash
chmod +x setup.sh run_app.sh
```

4. **Virtual Environment Issues**
- If the virtual environment isn't working, try removing and recreating it:
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Building a Standalone Application

To create a standalone application:

1. **Ensure PyInstaller is installed**:
```bash
pip install PyInstaller
```

2. **Build the application**:
```bash
python build_app.py
```

The standalone application will be created in the `dist` directory.

## Testing

To run the test suite:

```bash
pytest test_chatgpt_app.py -v
```

## Support

If you encounter any issues:
1. Check the application logs
2. Verify your Python version: `python --version`
3. Make sure all dependencies are correctly installed
4. Ensure your OpenAI API key is valid and has sufficient credits

## Security Notes

- Never share your `.env` file or API key
- The application stores your API key securely using the system keyring
- Always use the virtual environment to maintain clean dependencies
