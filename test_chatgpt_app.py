import unittest
from unittest.mock import MagicMock, patch
from PyQt6.QtWidgets import QApplication, QDialog
from PyQt6.QtCore import Qt
import sys
import os
from chatgpt_app import ChatGPTApp, ApiKeyDialog
from config_manager import ConfigManager

class TestChatGPTApp(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Create QApplication instance for GUI tests
        cls.app = QApplication(sys.argv)
        # Mock environment variables
        os.environ['OPENAI_API_KEY'] = 'sk-test123456789'

    def setUp(self):
        self.chat_app = ChatGPTApp()

    def tearDown(self):
        self.chat_app.close()

    @patch('openai.OpenAI')
    def test_initialization(self, mock_openai):
        # Test window title
        self.assertEqual(self.chat_app.windowTitle(), "ChatGPT Assistant")
        
        # Test window dimensions from settings
        settings = ConfigManager.get_app_settings()
        geometry = self.chat_app.geometry()
        self.assertEqual(geometry.width(), settings['window_width'])
        self.assertEqual(geometry.height(), settings['window_height'])
        
        # Test UI components
        self.assertIsNotNone(self.chat_app.chat_display)
        self.assertIsNotNone(self.chat_app.input_field)
        self.assertIsNotNone(self.chat_app.send_button)
        
        # Test that chat display is read-only
        self.assertTrue(self.chat_app.chat_display.isReadOnly())

    @patch('openai.OpenAI')
    def test_send_message_empty(self, mock_openai):
        # Test empty message handling
        self.chat_app.input_field.setText("")
        initial_text = self.chat_app.chat_display.toPlainText()
        self.chat_app.send_message()
        after_text = self.chat_app.chat_display.toPlainText()
        self.assertEqual(initial_text, after_text)

    @patch('openai.OpenAI')
    def test_send_message_success(self, mock_openai):
        # Mock OpenAI response
        mock_message = MagicMock()
        mock_message.role = "assistant"
        mock_message.content = [MagicMock(text=MagicMock(value="Test response"))]
        
        mock_messages = MagicMock()
        mock_messages.data = [mock_message]
        
        mock_openai.return_value.beta.threads.messages.list.return_value = mock_messages
        mock_openai.return_value.beta.threads.runs.retrieve.return_value.status = 'completed'
        
        # Test message sending
        test_message = "Hello, Assistant!"
        self.chat_app.input_field.setText(test_message)
        self.chat_app.send_message()
        
        # Verify input field is cleared
        self.assertEqual(self.chat_app.input_field.text(), "")
        
        # Verify message appears in chat display
        chat_text = self.chat_app.chat_display.toPlainText()
        self.assertIn(test_message, chat_text)
        self.assertIn("Test response", chat_text)

    @patch('openai.OpenAI')
    def test_api_key_validation(self, mock_openai):
        # Test valid API key
        self.assertTrue(ConfigManager.validate_api_key("sk-test123456789"))
        
        # Test invalid API keys
        self.assertFalse(ConfigManager.validate_api_key(""))
        self.assertFalse(ConfigManager.validate_api_key("invalid-key"))
        self.assertFalse(ConfigManager.validate_api_key("sk-too-short"))

    def test_ui_components_state(self):
        # Test initial state of UI components
        self.assertTrue(self.chat_app.input_field.isEnabled())
        self.assertTrue(self.chat_app.send_button.isEnabled())
        self.assertTrue(self.chat_app.chat_display.isReadOnly())
        
        # Test placeholder text
        self.assertEqual(
            self.chat_app.input_field.placeholderText(),
            "Type your message here..."
        )

class TestApiKeyDialog(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QApplication(sys.argv)

    def setUp(self):
        self.dialog = ApiKeyDialog()

    def tearDown(self):
        self.dialog.close()

    def test_dialog_initialization(self):
        # Test dialog properties
        self.assertEqual(self.dialog.windowTitle(), "OpenAI API Key")
        self.assertTrue(self.dialog.isModal())
        
        # Test input field properties
        self.assertTrue(hasattr(self.dialog, 'api_key_input'))
        self.assertEqual(
            self.dialog.api_key_input.echoMode(),
            QLineEdit.EchoMode.Password
        )

if __name__ == '__main__':
    unittest.main()
