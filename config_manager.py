import os
import keyring
from dotenv import load_dotenv
from PyQt6.QtWidgets import QMessageBox

class ConfigManager:
    """Manage application configuration and API key storage."""
    
    SERVICE_NAME = "ChatGPT_Assistant"
    API_KEY_NAME = "OPENAI_API_KEY"

    @staticmethod
    def initialize_config():
        """Initialize configuration and load API key from keychain."""
        return ConfigManager.get_api_key()

    @staticmethod
    def migrate_from_env():
        """Migrate API key from .env file to keychain if needed."""
        if os.path.exists('.env'):
            load_dotenv()
            api_key = os.getenv(ConfigManager.API_KEY_NAME)
            if api_key and ConfigManager.validate_api_key(api_key):
                ConfigManager.save_api_key(api_key)
                try:
                    os.remove('.env')
                except:
                    pass

    @staticmethod
    def get_api_key():
        """Get API key from keychain."""
        try:
            api_key = keyring.get_password(ConfigManager.SERVICE_NAME, ConfigManager.API_KEY_NAME)
            # Migrate from .env if no key in keychain
            if not api_key:
                ConfigManager.migrate_from_env()
                api_key = keyring.get_password(ConfigManager.SERVICE_NAME, ConfigManager.API_KEY_NAME)
            return api_key
        except Exception as e:
            print(f"Error getting API key: {e}")  # For debugging
            return None

    @staticmethod
    def has_api_key():
        """Check if API key exists in keychain."""
        try:
            return bool(ConfigManager.get_api_key())
        except:
            return False

    @staticmethod
    def save_api_key(api_key):
        """Save API key to keychain securely."""
        try:
            keyring.set_password(ConfigManager.SERVICE_NAME, ConfigManager.API_KEY_NAME, api_key)
            return True
        except Exception as e:
            print(f"Error saving API key: {e}")  # For debugging
            return False

    @staticmethod
    def remove_api_key():
        """Remove API key from keychain."""
        try:
            keyring.delete_password(ConfigManager.SERVICE_NAME, ConfigManager.API_KEY_NAME)
            return True
        except keyring.errors.PasswordDeleteError:
            # Key doesn't exist, that's fine
            return True
        except Exception as e:
            print(f"Error removing API key: {e}")  # For debugging
            return False

    @staticmethod
    def validate_api_key(api_key):
        """Validate API key format."""
        if not api_key:
            return False
        
        # Basic validation for OpenAI API key format
        return api_key.startswith('sk-') and len(api_key) > 20

    @staticmethod
    def get_app_settings():
        """Get application settings."""
        return {
            'window_width': 800,
            'window_height': 600,
            'font_size': 12,
            'model': 'gpt-4-1106-preview',
            'max_tokens': 1000,
            'temperature': 0.7
        }
