import sys
import time
import os
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QTextEdit, QLineEdit, QPushButton, QMessageBox,
                            QDialog, QLabel, QHBoxLayout, QSpacerItem, QSizePolicy,
                            QMenu, QAction, QFileDialog, QStatusBar)
from PyQt6.QtCore import Qt, QSize, QTimer
from PyQt6.QtGui import QFont, QIcon, QTextCursor, QPalette, QColor
from version_checker import VersionChecker, show_update_dialog

class CustomStatusBar(QStatusBar):
    """Custom status bar with better visibility."""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            QStatusBar {
                border-top: 1px solid #ccc;
                background-color: #f8f8f8;
                padding: 3px;
                color: #444;
            }
        """)
        self.setSizeGripEnabled(False)
import openai
from config_manager import ConfigManager

class ApiKeyDialog(QDialog):
    def __init__(self, parent=None, first_run=False):
        super().__init__(parent)
        self.setWindowTitle("API Key Setup" if first_run else "Update API Key")
        self.setModal(True)
        self.setMinimumWidth(500)
        self.first_run = first_run
        self.setup_ui()
    
    def setup_ui(self):
        """Set up the dialog UI."""
        layout = QVBoxLayout(self)
        layout.setSpacing(15)
        
        if self.first_run:
            # Add welcome message
            welcome = QLabel("Set Up Your API Key")
            welcome.setStyleSheet("""
                QLabel {
                    font-size: 20px;
                    font-weight: bold;
                    color: #0084ff;
                    margin: 10px 0;
                }
            """)
            layout.addWidget(welcome)
            
            # Add explanatory text
            explanation = QLabel(
                "To use ChatGPT Assistant, you need an OpenAI API key. "
                "This key allows secure access to ChatGPT's features."
            )
            explanation.setWordWrap(True)
            explanation.setStyleSheet("font-size: 13px; margin-bottom: 10px;")
            layout.addWidget(explanation)
        
        # Add get API key instructions in a nice box
        instructions_box = QWidget()
        instructions_box.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                border-radius: 8px;
                padding: 15px;
            }
        """)
        box_layout = QVBoxLayout(instructions_box)
        
        instructions_header = QLabel("How to Get Your API Key:")
        instructions_header.setStyleSheet("font-weight: bold; font-size: 13px;")
        box_layout.addWidget(instructions_header)
        
        steps = QLabel(
            "1. Visit <a href='https://platform.openai.com/api-keys' style='color: #0084ff;'>"
            "platform.openai.com/api-keys</a><br>"
            "2. Sign in or create an OpenAI account<br>"
            "3. Click 'Create new secret key'<br>"
            "4. Copy your new API key (starts with 'sk-')"
        )
        steps.setOpenExternalLinks(True)
        steps.setTextFormat(Qt.RichText)
        steps.setStyleSheet("font-size: 13px; margin: 5px 0;")
        box_layout.addWidget(steps)
        
        layout.addWidget(instructions_box)
        
        # Create input section with a different background
        input_box = QWidget()
        input_box.setStyleSheet("""
            QWidget {
                background-color: white;
                border: 1px solid #e1e4e8;
                border-radius: 8px;
                padding: 15px;
            }
        """)
        input_layout = QVBoxLayout(input_box)
        
        # API Key input with icon
        key_label = QLabel("Enter your OpenAI API Key:")
        key_label.setStyleSheet("font-weight: bold; font-size: 13px;")
        input_layout.addWidget(key_label)
        
        input_container = QWidget()
        input_container.setStyleSheet("""
            QWidget {
                background-color: white;
                border: none;
            }
        """)
        input_container_layout = QHBoxLayout(input_container)
        input_container_layout.setContentsMargins(0, 0, 0, 0)
        
        self.api_key_input = QLineEdit()
        self.api_key_input.setEchoMode(QLineEdit.EchoMode.Password)
        self.api_key_input.setPlaceholderText("sk-...")
        self.api_key_input.textChanged.connect(self.validate_input)
        self.api_key_input.setStyleSheet("""
            QLineEdit {
                padding: 8px 8px 8px 30px;  /* Left padding for icon */
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 13px;
            }
            QLineEdit:focus {
                border-color: #0084ff;
            }
        """)
        
        # Create container for input and validation icon
        input_with_icon = QWidget()
        input_with_icon_layout = QHBoxLayout(input_with_icon)
        input_with_icon_layout.setContentsMargins(0, 0, 0, 0)
        input_with_icon_layout.setSpacing(0)
        
        # Add validation status icon
        self.validation_icon = QLabel()
        self.validation_icon.setFixedSize(20, 20)
        self.validation_icon.setStyleSheet("""
            QLabel {
                margin-right: -25px;  /* Overlay with input field */
                z-index: 1;           /* Show icon above input field */
                padding: 0 5px;
            }
        """)
        input_with_icon_layout.addWidget(self.validation_icon)
        input_with_icon_layout.addWidget(self.api_key_input)
        
        input_container_layout.addWidget(input_with_icon)
        
        # Show/Hide password button
        self.show_hide_button = QPushButton("Show")
        self.show_hide_button.setCheckable(True)
        self.show_hide_button.setStyleSheet("""
            QPushButton {
                padding: 8px 12px;
                border: 1px solid #ccc;
                border-radius: 4px;
                background: #f8f9fa;
            }
            QPushButton:hover {
                background: #e9ecef;
            }
        """)
        self.show_hide_button.clicked.connect(self.toggle_password_visibility)
        input_container_layout.addWidget(self.show_hide_button)
        
        input_layout.addWidget(input_container)
        layout.addWidget(input_box)
        
        # Add security note with icon
        security_box = QWidget()
        security_box.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                border-radius: 8px;
                padding: 10px;
            }
        """)
        security_layout = QHBoxLayout(security_box)
        
        lock_icon = QLabel("🔒")
        lock_icon.setStyleSheet("font-size: 16px;")
        security_layout.addWidget(lock_icon)
        
        security_note = QLabel(
            "Your API key will be stored securely in your Mac's Keychain. "
            "You won't need to enter it again."
        )
        security_note.setStyleSheet("color: #666; font-size: 12px;")
        security_note.setWordWrap(True)
        security_layout.addWidget(security_note, stretch=1)
        
        layout.addWidget(security_box)
        
        # Add buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()
        
        cancel_button = QPushButton("Cancel")
        cancel_button.setStyleSheet("""
            QPushButton {
                padding: 8px 20px;
                border: 1px solid #ccc;
                border-radius: 4px;
                background: white;
            }
            QPushButton:hover {
                background: #f8f9fa;
            }
        """)
        
        self.save_button = QPushButton("Save API Key")
        self.save_button.setEnabled(False)
        self.save_button.setStyleSheet("""
            QPushButton {
                padding: 8px 20px;
                background-color: #0084ff;
                color: white;
                border: none;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #0073e6;
            }
            QPushButton:disabled {
                background-color: #ccc;
            }
        """)
        
        button_layout.addWidget(cancel_button)
        button_layout.addWidget(self.save_button)
        layout.addLayout(button_layout)

        # Connect button signals
        self.save_button.clicked.connect(self.accept)
        cancel_button.clicked.connect(self.reject)

        # Set focus to input field
        self.api_key_input.setFocus()

    def validate_input(self):
        """Enable save button and show validation status."""
        api_key = self.api_key_input.text().strip()
        
        # Base style for input field
        base_style = """
            QLineEdit {
                padding: 8px 8px 8px 30px;
                border-radius: 4px;
                font-size: 13px;
            }
        """
        
        if not api_key:
            # Empty input
            self.validation_icon.setText("")
            self.save_button.setEnabled(False)
            self.api_key_input.setStyleSheet(base_style + """
                QLineEdit {
                    border: 1px solid #ccc;
                }
                QLineEdit:focus {
                    border-color: #0084ff;
                }
            """)
            self.statusBar().clearMessage()
        else:
            # Check format
            valid_format = api_key.startswith('sk-') and len(api_key) > 20
            
            if valid_format:
                # Valid format
                self.validation_icon.setText("✓")
                self.validation_icon.setStyleSheet("""
                    QLabel {
                        color: #28a745;
                        font-weight: bold;
                        margin-right: -25px;
                        z-index: 1;
                        padding: 0 5px;
                    }
                """)
                self.api_key_input.setStyleSheet(base_style + """
                    QLineEdit {
                        border: 1px solid #28a745;
                    }
                """)
                self.save_button.setEnabled(True)
                self.statusBar().showMessage("API key format is valid", 2000)
            else:
                # Invalid format
                self.validation_icon.setText("×")
                self.validation_icon.setStyleSheet("""
                    QLabel {
                        color: #dc3545;
                        font-weight: bold;
                        margin-right: -25px;
                        z-index: 1;
                        padding: 0 5px;
                    }
                """)
                self.api_key_input.setStyleSheet(base_style + """
                    QLineEdit {
                        border: 1px solid #dc3545;
                    }
                """)
                self.save_button.setEnabled(False)
                
                # Show specific error message
                if not api_key.startswith('sk-'):
                    self.statusBar().showMessage("API key must start with 'sk-'", 2000)
                else:
                    self.statusBar().showMessage("API key is too short", 2000)

    def toggle_password_visibility(self):
        """Toggle between showing and hiding the API key."""
        if self.show_hide_button.isChecked():
            self.api_key_input.setEchoMode(QLineEdit.EchoMode.Normal)
            self.show_hide_button.setText("Hide")
        else:
            self.api_key_input.setEchoMode(QLineEdit.EchoMode.Password)
            self.show_hide_button.setText("Show")

class LoadingDialog(QDialog):
    """Show a loading indicator with message."""
    def __init__(self, message="Please wait...", parent=None):
        super().__init__(parent)
        self.setWindowTitle(" ")
        self.setModal(True)
        self.setFixedSize(300, 100)
        self.setup_ui(message)
        
        # Remove window decoration
        self.setWindowFlags(Qt.Dialog | Qt.FramelessWindowHint)
        
    def setup_ui(self, message):
        """Set up the loading dialog UI."""
        layout = QVBoxLayout(self)
        layout.setSpacing(15)
        
        # Add spinning indicator emoji
        loading_label = QLabel("⏳")
        loading_label.setStyleSheet("font-size: 24px;")
        loading_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(loading_label)
        
        # Add message
        message_label = QLabel(message)
        message_label.setStyleSheet("color: #666; font-size: 13px;")
        message_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(message_label)
        
        # Center the dialog on the parent window
        if self.parent():
            parent_center = self.parent().geometry().center()
            self.move(parent_center.x() - self.width()/2, parent_center.y() - self.height()/2)

class WelcomeDialog(QDialog):
    """Welcome screen shown on first run."""
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Welcome to ChatGPT Assistant")
        self.setModal(True)
        self.setMinimumWidth(650)
        self.setup_ui()
    
    def setup_ui(self):
        """Set up the welcome dialog UI."""
        layout = QVBoxLayout(self)
        layout.setSpacing(20)
        
        # Greeting section with icon
        greeting_widget = QWidget()
        greeting_widget.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                border-radius: 10px;
                padding: 20px;
            }
        """)
        greeting_layout = QHBoxLayout(greeting_widget)
        
        # App icon (emoji as placeholder, you can replace with actual icon)
        icon_label = QLabel("🤖")
        icon_label.setStyleSheet("font-size: 48px;")
        greeting_layout.addWidget(icon_label)
        
        greeting_text = QWidget()
        greeting_text_layout = QVBoxLayout(greeting_text)
        greeting_text_layout.setSpacing(5)
        
        header = QLabel("Welcome to ChatGPT Assistant!")
        header.setStyleSheet("font-size: 24px; font-weight: bold; color: #0084ff;")
        greeting_text_layout.addWidget(header)
        
        subheader = QLabel("Let's get you set up in just a few minutes.")
        subheader.setStyleSheet("font-size: 14px; color: #666;")
        greeting_text_layout.addWidget(subheader)
        
        greeting_layout.addWidget(greeting_text, stretch=1)
        layout.addWidget(greeting_widget)
        
        # What you'll need section
        requirements = QLabel("What you'll need:")
        requirements.setStyleSheet("font-size: 16px; font-weight: bold; margin-top: 10px;")
        layout.addWidget(requirements)
        
        req_list = QLabel(
            "• An OpenAI account (free to create)\n"
            "• An API key from OpenAI (we'll help you get one)\n"
            "• About 2 minutes of your time"
        )
        req_list.setStyleSheet("font-size: 14px; margin: 10px 0;")
        layout.addWidget(req_list)
        
        # Steps section
        steps_widget = QWidget()
        steps_widget.setStyleSheet("""
            QWidget {
                background-color: white;
                border: 1px solid #e1e4e8;
                border-radius: 10px;
                padding: 20px;
            }
        """)
        steps_layout = QVBoxLayout(steps_widget)
        
        steps_header = QLabel("Getting your API key is easy:")
        steps_header.setStyleSheet("font-size: 16px; font-weight: bold;")
        steps_layout.addWidget(steps_header)
        
        steps = [
            ("1", "Visit OpenAI", "Click here: <a href='https://platform.openai.com/api-keys' style='color: #0084ff;'>platform.openai.com/api-keys</a>"),
            ("2", "Sign in or create account", "It's free and takes less than a minute"),
            ("3", "Create new key", "Click the 'Create new secret key' button"),
            ("4", "Copy your key", "It will start with 'sk-'"),
            ("5", "Return here", "We'll help you set it up securely")
        ]
        
        for num, title, desc in steps:
            step_widget = QWidget()
            step_layout = QHBoxLayout(step_widget)
            step_layout.setSpacing(15)
            
            # Step number in circle
            number = QLabel(num)
            number.setStyleSheet("""
                QLabel {
                    background-color: #0084ff;
                    color: white;
                    border-radius: 12px;
                    padding: 5px;
                    min-width: 24px;
                    min-height: 24px;
                    qproperty-alignment: AlignCenter;
                }
            """)
            step_layout.addWidget(number)
            
            # Step content
            content = QWidget()
            content_layout = QVBoxLayout(content)
            content_layout.setSpacing(2)
            
            step_title = QLabel(title)
            step_title.setStyleSheet("font-weight: bold; font-size: 14px;")
            content_layout.addWidget(step_title)
            
            step_desc = QLabel(desc)
            step_desc.setTextFormat(Qt.RichText)
            step_desc.setOpenExternalLinks(True)
            step_desc.setStyleSheet("color: #666; font-size: 12px;")
            content_layout.addWidget(step_desc)
            
            step_layout.addWidget(content, stretch=1)
            steps_layout.addWidget(step_widget)
        
        layout.addWidget(steps_widget)
        
        # Final section with security note and action button
        final_section = QWidget()
        final_section.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                border-radius: 10px;
                padding: 20px;
                margin-top: 10px;
            }
        """)
        final_layout = QVBoxLayout(final_section)
        
        # Security message with icon
        security_widget = QWidget()
        security_layout = QHBoxLayout(security_widget)
        security_layout.setSpacing(15)
        
        lock_icon = QLabel("🔒")
        lock_icon.setStyleSheet("font-size: 24px;")
        security_layout.addWidget(lock_icon)
        
        security_text = QLabel(
            "<b>Your API key is secure with us</b><br>"
            "We store it safely in your Mac's Keychain, and you'll only need to enter it once."
        )
        security_text.setTextFormat(Qt.RichText)
        security_text.setWordWrap(True)
        security_text.setStyleSheet("font-size: 13px; color: #666;")
        security_layout.addWidget(security_text, stretch=1)
        
        final_layout.addWidget(security_widget)
        
        # Ready to start section
        ready_widget = QWidget()
        ready_layout = QHBoxLayout(ready_widget)
        
        ready_text = QLabel("Ready to get started?")
        ready_text.setStyleSheet("font-size: 14px; color: #666;")
        ready_layout.addWidget(ready_text)
        
        ready_layout.addStretch()
        
        start_button = QPushButton("Let's Set Up Your API Key →")
        start_button.setStyleSheet("""
            QPushButton {
                background-color: #0084ff;
                color: white;
                border: none;
                border-radius: 5px;
                padding: 12px 24px;
                font-size: 14px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #0073e6;
            }
        """)
        start_button.clicked.connect(self.accept)
        ready_layout.addWidget(start_button)
        
        final_layout.addWidget(ready_widget)
        
        layout.addWidget(final_section)

class ChatGPTApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("ChatGPT Assistant")
        
        # Get application version
        self.version = self._get_app_version()
        self.setWindowTitle(f"ChatGPT Assistant {self.version}")
        
        # Load settings
        settings = ConfigManager.get_app_settings()
        self.setGeometry(100, 100, settings['window_width'], settings['window_height'])
        
        # Initialize version checker
        self.version_checker = VersionChecker(self.version, self)
        self.version_checker.update_available.connect(self._handle_update_available)
        
        # Schedule version check
        QTimer.singleShot(3000, self._check_for_updates)  # Check after 3 seconds
        
        # Set application-wide style
        self.setStyleSheet("""
            QMainWindow {
                background-color: #f5f5f5;
            }
            QTextEdit, QLineEdit {
                background-color: white;
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 8px;
                selection-background-color: #0084ff;
                selection-color: white;
            }
            QPushButton {
                background-color: #0084ff;
                color: white;
                border: none;
                border-radius: 5px;
                padding: 8px 20px;
                min-width: 80px;
            }
            QPushButton:hover {
                background-color: #0073e6;
            }
            QPushButton:pressed {
                background-color: #0062cc;
            }
            QPushButton:disabled {
                background-color: #ccc;
            }
            QMenuBar {
                background-color: #f8f8f8;
                border-bottom: 1px solid #ddd;
            }
            QMenu {
                background-color: white;
                border: 1px solid #ddd;
            }
            QMenu::item:selected {
                background-color: #0084ff;
                color: white;
            }
        """)
        
        # Create status bar
        self.setStatusBar(CustomStatusBar(self))
        self.statusBar().showMessage("Ready", 2000)
        
        # Load API key and initialize OpenAI client
        self.initialize_api_key()
        
        # Initialize chat history
        self.messages = []
        
        # Check if this is the first run
        self.check_first_run()
        
    def check_first_run(self):
        """Show welcome message and instructions on first run."""
        first_run_file = ".first_run"
        if not os.path.exists(first_run_file):
            welcome_msg = """Welcome to ChatGPT Assistant! 👋

Quick Tips:
• Type your message in the box below and press Enter or click Send
• The assistant will respond in a few seconds
• Your chat history will be displayed above
• You can resize this window as needed

Example questions to get started:
1. "What's the weather like today?"
2. "Help me write a professional email"
3. "Explain a complex topic in simple terms"

Your API key is securely stored and messages are sent directly to OpenAI.

Enjoy using ChatGPT Assistant! 🚀
"""
            self.chat_display.append(welcome_msg)
            
            # Create first run file to prevent showing this again
            with open(first_run_file, "w") as f:
                f.write("1")
        
        # Set up the UI
        self.setup_ui()
        
        # Initialize the assistant
        self.initialize_assistant()

    def initialize_api_key(self):
        """Initialize OpenAI API key and client."""
        api_key = ConfigManager.initialize_config()
        first_run = not ConfigManager.has_api_key()

        # If no API key, show welcome screen and setup dialog
        if not api_key:
            # Show welcome screen first
            welcome = WelcomeDialog(self)
            welcome.exec()

        # Keep asking for API key until valid or user quits
        while not api_key or not ConfigManager.validate_api_key(api_key):
            dialog = ApiKeyDialog(self, first_run=first_run)
            result = dialog.exec()
            
            if result == QDialog.DialogCode.Accepted:
                api_key = dialog.api_key_input.text().strip()
                if not ConfigManager.validate_api_key(api_key):
                    QMessageBox.warning(self, "Invalid Format",
                        "The API key should start with 'sk-' and be longer than 20 characters.\n"
                        "Please check that you copied the entire key.")
                    continue

                # Test the API key with loading dialog
                loading = LoadingDialog("Validating your API key...", self)
                loading.show()
                QApplication.processEvents()
                
                try:
                    openai.api_key = api_key
                    client = openai.OpenAI()
                    client.models.list()  # Simple API test
                    
                    # Save valid key securely
                    ConfigManager.save_api_key(api_key)
                    
                    loading.hide()
                    if first_run:
                        QMessageBox.information(self, "Setup Complete",
                            "✨ Great! Your API key is working and has been securely saved.\n\n"
                            "You can now start chatting with ChatGPT Assistant!")
                    else:
                        self.statusBar().showMessage("API key validated and saved securely", 3000)
                    break
                except Exception as e:
                    error_msg = str(e).lower()
                    if "api key" in error_msg or "authentication" in error_msg:
                        QMessageBox.warning(self, "Invalid API Key",
                            "The API key was not accepted by OpenAI.\n"
                            "Please check that you copied it correctly.")
                    else:
                        QMessageBox.warning(self, "Connection Error",
                            "Could not connect to OpenAI.\n"
                            "Please check your internet connection.")
                    continue
            else:
                # User cancelled
                self.statusBar().showMessage("API key required to use the application", 5000)
                sys.exit(0)

    def setup_ui(self):
        """Set up the user interface."""
        # Create central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        
        # Create chat display with improved styling
        self.chat_display = QTextEdit()
        self.chat_display.setReadOnly(True)
        font = QFont("Arial", 12)
        self.chat_display.setFont(font)
        self.chat_display.setStyleSheet("""
            QTextEdit {
                background-color: white;
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 10px;
            }
        """)
        self.chat_display.setContextMenuPolicy(Qt.CustomContextMenu)
        self.chat_display.customContextMenuRequested.connect(self.show_context_menu)
        layout.addWidget(self.chat_display)

    def show_context_menu(self, position):
        """Show custom context menu for chat display."""
        context_menu = QMenu(self)

        # Add Copy action
        copy_action = context_menu.addAction("Copy")
        copy_action.setEnabled(self.chat_display.textCursor().hasSelection())
        copy_action.triggered.connect(self.chat_display.copy)

        # Add Copy All action
        copy_all_action = context_menu.addAction("Copy All")
        copy_all_action.triggered.connect(self.copy_all_text)

        context_menu.addSeparator()

        # Add Clear action
        clear_action = context_menu.addAction("Clear Chat")
        clear_action.triggered.connect(self.chat_display.clear)

        # Show menu at cursor position
        context_menu.exec_(self.chat_display.mapToGlobal(position))

    def copy_all_text(self):
        """Copy all text from chat display to clipboard."""
        cursor = self.chat_display.textCursor()
        cursor.select(QTextCursor.Document)
        self.chat_display.setTextCursor(cursor)
        self.chat_display.copy()
        cursor.clearSelection()
        self.chat_display.setTextCursor(cursor)

        # Show brief success message
        self.statusBar().showMessage("Chat copied to clipboard", 2000)
        
        # Create input area with horizontal layout
        input_layout = QHBoxLayout()
        
        # Create input field with styling
        self.input_field = QLineEdit()
        self.input_field.setFont(font)
        self.input_field.setPlaceholderText("Type your message here...")
        self.input_field.setStyleSheet("""
            QLineEdit {
                border: 1px solid #ccc;
                border-radius: 5px;
                padding: 8px;
                min-height: 20px;
            }
        """)
        self.input_field.returnPressed.connect(self.send_message)
        input_layout.addWidget(self.input_field)
        
        # Create loading indicator
        self.loading_label = QLabel("Processing...")
        self.loading_label.setFont(font)
        self.loading_label.setStyleSheet("""
            QLabel {
                color: #666;
                padding: 5px;
            }
        """)
        self.loading_label.hide()
        input_layout.addWidget(self.loading_label)
        
        # Create send button with styling
        self.send_button = QPushButton("Send")
        self.send_button.setFont(font)
        self.send_button.setStyleSheet("""
            QPushButton {
                background-color: #0084ff;
                color: white;
                border: none;
                border-radius: 5px;
                padding: 8px 20px;
                min-width: 80px;
            }
            QPushButton:hover {
                background-color: #0073e6;
            }
            QPushButton:pressed {
                background-color: #0062cc;
            }
            QPushButton:disabled {
                background-color: #ccc;
            }
        """)
        self.send_button.clicked.connect(self.send_message)
        input_layout.addWidget(self.send_button)
        
        layout.addLayout(input_layout)

    def initialize_assistant(self):
        """Initialize the OpenAI assistant."""
        try:
            settings = ConfigManager.get_app_settings()
            self.client = openai.OpenAI()
            self.assistant = self.client.beta.assistants.create(
                name="Mac App Assistant",
                instructions="You are a helpful assistant responding to user queries.",
                model=settings['model']
            )
            self.thread = self.client.beta.threads.create()
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to initialize OpenAI assistant: {str(e)}")

    def send_message(self):
        """Send a message and get the assistant's response."""
        user_input = self.input_field.text().strip()
        if not user_input:
            return
        
        # Disable input and show loading indicators
        self.input_field.setEnabled(False)
        self.send_button.setEnabled(False)
        self.loading_label.show()
        
        # Clear input field and display user message
        self.input_field.clear()
        self.chat_display.append(f"\nYou: {user_input}")
        self.chat_display.ensureCursorVisible()
        
        # Show processing message
        self.chat_display.append("\n[Assistant is thinking...]")
        QApplication.processEvents()  # Update UI immediately
        
        try:
            # Add the user message to the thread
            self.client.beta.threads.messages.create(
                thread_id=self.thread.id,
                role="user",
                content=user_input
            )
            
            # Run the assistant
            run = self.client.beta.threads.runs.create(
                thread_id=self.thread.id,
                assistant_id=self.assistant.id
            )
            
            # Wait for the response
            while True:
                run_status = self.client.beta.threads.runs.retrieve(
                    thread_id=self.thread.id,
                    run_id=run.id
                )
                if run_status.status == 'completed':
                    break
                elif run_status.status == 'failed':
                    raise Exception("Assistant failed to process the message")
            
            # Remove the "thinking" message
            current_text = self.chat_display.toPlainText()
            if "[Assistant is thinking...]" in current_text:
                self.chat_display.setText(current_text.replace("\n[Assistant is thinking...]", ""))
            
            # Get the assistant's response
            messages = self.client.beta.threads.messages.list(
                thread_id=self.thread.id
            )
            
            for message in messages:
                if message.role == "assistant":
                    assistant_response = message.content[0].text.value
                    
                    # Display "Assistant: " first
                    self.chat_display.append("\nAssistant: ")
                    QApplication.processEvents()
                    
                    # Display response with typing effect
                    for char in assistant_response:
                        self.chat_display.insertPlainText(char)
                        if char in ['.', '!', '?', '\n']:
                            QApplication.processEvents()
                            time.sleep(0.1)
                        elif char == ' ':
                            QApplication.processEvents()
                            time.sleep(0.03)
                    
                    # Ensure chat is scrolled to bottom
                    self.chat_display.verticalScrollBar().setValue(
                        self.chat_display.verticalScrollBar().maximum()
                    )
                    break
                    
        except Exception as e:
            error_msg = str(e)
            if "API key" in error_msg.lower():
                QMessageBox.critical(self, "API Key Error",
                    "There was a problem with your API key. Please check that:\n\n"
                    "1. Your API key is valid\n"
                    "2. You have credit available\n"
                    "3. The key is correctly formatted (starts with 'sk-')\n\n"
                    "You may need to run setup.sh again to reconfigure your API key.")
            elif "connect" in error_msg.lower():
                QMessageBox.critical(self, "Connection Error",
                    "Failed to connect to OpenAI servers. Please check:\n\n"
                    "1. Your internet connection is working\n"
                    "2. You can access api.openai.com\n"
                    "3. Your firewall isn't blocking the connection\n\n"
                    "Try again in a few moments.")
            else:
                QMessageBox.critical(self, "Error",
                    f"An unexpected error occurred:\n\n{error_msg}\n\n"
                    "If this persists, try:\n"
                    "1. Clearing the chat history\n"
                    "2. Restarting the application\n"
                    "3. Running setup.sh again")
            
            # Remove the "thinking" message if it exists
            current_text = self.chat_display.toPlainText()
            if "[Assistant is thinking...]" in current_text:
                self.chat_display.setText(current_text.replace("\n[Assistant is thinking...]", ""))
        
        finally:
            # Hide loading indicator and re-enable input
            self.loading_label.hide()
            self.input_field.setEnabled(True)
            self.send_button.setEnabled(True)
            self.input_field.setFocus()
            
            # Ensure the chat display scrolls to the bottom
            self.chat_display.verticalScrollBar().setValue(
                self.chat_display.verticalScrollBar().maximum()
            )

    def create_menu(self):
        """Create application menu bar with keyboard shortcuts."""
        menubar = self.menuBar()
        
        # File Menu
        file_menu = menubar.addMenu('&File')
        
        # Settings Menu
        settings_menu = menubar.addMenu('&Settings')
        
        # API Key management actions
        api_key_menu = QMenu('API Key', self)
        update_key_action = QAction('Update API Key...', self)
        update_key_action.setStatusTip('Change your OpenAI API key')
        update_key_action.triggered.connect(self.update_api_key)
        api_key_menu.addAction(update_key_action)
        
        reset_key_action = QAction('Reset API Key...', self)
        reset_key_action.setStatusTip('Remove saved API key and enter a new one')
        reset_key_action.triggered.connect(self.reset_api_key)
        api_key_menu.addAction(reset_key_action)
        
        settings_menu.addMenu(api_key_menu)
        
        # Clear Chat action
        clear_action = QAction('&Clear Chat', self)
        clear_action.setShortcut('Ctrl+L')
        clear_action.setStatusTip('Clear the chat history')
        clear_action.triggered.connect(self.clear_chat)
        file_menu.addAction(clear_action)
        
        # Save Chat action
        save_action = QAction('&Save Chat...', self)
        save_action.setShortcut('Ctrl+S')
        save_action.setStatusTip('Save chat history to a file')
        save_action.triggered.connect(self.save_chat)
        file_menu.addAction(save_action)
        
        # Open Saved Chat action
        open_action = QAction('&Open Saved Chat...', self)
        open_action.setShortcut('Ctrl+O')
        open_action.setStatusTip('Open a previously saved chat')
        open_action.triggered.connect(self.open_saved_chat)
        file_menu.addAction(open_action)
        
        file_menu.addSeparator()
        
        # Exit action
        exit_action = QAction('&Exit', self)
        exit_action.setShortcut('Ctrl+Q')
        exit_action.setStatusTip('Exit application')
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)
        
        # Edit Menu
        edit_menu = menubar.addMenu('&Edit')
        
        # Copy action
        copy_action = QAction('&Copy', self)
        copy_action.setShortcut('Ctrl+C')
        copy_action.setStatusTip('Copy selected text')
        copy_action.triggered.connect(self.chat_display.copy)
        edit_menu.addAction(copy_action)
        
        # Copy All action
        copy_all_action = QAction('Copy &All', self)
        copy_all_action.setShortcut('Ctrl+Shift+C')
        copy_all_action.setStatusTip('Copy entire chat history')
        copy_all_action.triggered.connect(self.copy_all_text)
        edit_menu.addAction(copy_all_action)
        
        # Help Menu
        help_menu = menubar.addMenu('&Help')
        
        # Tips action
        tips_action = QAction('Usage &Tips', self)
        tips_action.setShortcut('Ctrl+T')
        tips_action.setStatusTip('Show usage tips')
        tips_action.triggered.connect(self.show_tips_dialog)
        help_menu.addAction(tips_action)
        
        help_menu.addSeparator()
        
        # API Key Help submenu
        api_help_menu = QMenu('API Key Help', self)
        
        fix_key_action = QAction('Fix API Key Issues...', self)
        fix_key_action.setStatusTip('Troubleshoot API key problems')
        fix_key_action.triggered.connect(self.show_api_help)
        api_help_menu.addAction(fix_key_action)
        
        update_key_action = QAction('Update API Key...', self)
        update_key_action.setStatusTip('Change your OpenAI API key')
        update_key_action.triggered.connect(self.update_api_key)
        api_help_menu.addAction(update_key_action)
        
        reset_key_action = QAction('Reset API Key...', self)
        reset_key_action.setStatusTip('Remove saved API key and enter a new one')
        reset_key_action.triggered.connect(self.reset_api_key)
        api_help_menu.addAction(reset_key_action)
        
        help_menu.addMenu(api_help_menu)
        
        help_menu.addSeparator()
        
        # Check for Updates action
        update_action = QAction('Check for &Updates', self)
        update_action.setStatusTip('Check for new versions')
        update_action.triggered.connect(self.check_updates_manually)
        help_menu.addAction(update_action)
        
        # About action
        about_action = QAction('&About', self)
        about_action.setShortcut('F1')
        about_action.setStatusTip('About ChatGPT Assistant')
        about_action.triggered.connect(self.show_about_dialog)
        help_menu.addAction(about_action)

    def show_api_help(self):
        """Show API key troubleshooting dialog."""
        help_dialog = QMessageBox(self)
        help_dialog.setWindowTitle("API Key Help")
        help_dialog.setIcon(QMessageBox.Icon.Information)
        
        help_text = """
        <h3>API Key Troubleshooting</h3>
        
        <p><b>Common Issues:</b></p>
        <ul>
        <li>Key starts with 'sk-'</li>
        <li>Key is complete (not partially copied)</li>
        <li>OpenAI account has available credits</li>
        <li>Internet connection is working</li>
        </ul>
        
        <p><b>How to Fix:</b></p>
        1. <a href='https://platform.openai.com/api-keys'>Check your API key</a> on OpenAI's website<br>
        2. Verify your <a href='https://platform.openai.com/account/usage'>account balance</a><br>
        3. Try updating your API key (Settings → API Key → Update)<br>
        4. If needed, create a new API key
        
        <p><b>Need More Help?</b></p>
        • Visit <a href='https://help.openai.com'>OpenAI's Help Center</a><br>
        • Check your <a href='https://platform.openai.com/account/limits'>rate limits</a><br>
        • Review the <a href='https://platform.openai.com/docs/guides/error-codes'>error codes guide</a>
        """
        
        help_dialog.setText("Having trouble with your API key?")
        help_dialog.setInformativeText(help_text)
        help_dialog.setTextFormat(Qt.RichText)
        
        # Add buttons
        help_dialog.addButton("Close", QMessageBox.ButtonRole.CloseRole)
        update_button = help_dialog.addButton("Update API Key", QMessageBox.ButtonRole.ActionRole)
        reset_button = help_dialog.addButton("Reset API Key", QMessageBox.ButtonRole.ActionRole)
        
        result = help_dialog.exec()
        
        # Handle button clicks
        if help_dialog.clickedButton() == update_button:
            self.update_api_key()
        elif help_dialog.clickedButton() == reset_button:
            self.reset_api_key()

    def update_api_key(self):
        """Allow user to update their API key."""
        # Show API key dialog
        dialog = ApiKeyDialog(self, first_run=False)
        if dialog.exec() == QDialog.DialogCode.Accepted:
            new_key = dialog.api_key_input.text().strip()
            
            # Validate new key
            if ConfigManager.validate_api_key(new_key):
                try:
                    # Test the new key
                    openai.api_key = new_key
                    client = openai.OpenAI()
                    client.models.list()  # Simple API test
                    
                    # Save the new key
                    ConfigManager.save_api_key(new_key)
                    self.statusBar().showMessage("API key updated successfully", 3000)
                    
                except Exception as e:
                    QMessageBox.warning(self, "Invalid API Key",
                        "Could not verify the new API key.\nPlease check that it is correct.")
                    return
            else:
                QMessageBox.warning(self, "Invalid Format",
                    "The API key should start with 'sk-' and be longer than 20 characters.")
                return

    def reset_api_key(self):
        """Remove saved API key and prompt for a new one."""
        reply = QMessageBox.question(
            self,
            "Reset API Key",
            "This will remove your saved API key and prompt for a new one.\n"
            "Would you like to continue?",
            QMessageBox.Yes | QMessageBox.No,
            QMessageBox.No
        )
        
        if reply == QMessageBox.Yes:
            try:
                # Remove the key from keychain
                ConfigManager.remove_api_key()
                self.statusBar().showMessage("API key removed", 2000)
                
                # Reinitialize with new key
                self.initialize_api_key()
                self.statusBar().showMessage("New API key saved successfully", 3000)
                
            except Exception as e:
                QMessageBox.critical(self, "Error",
                    "Failed to reset API key. Please try again.")

    def check_updates_manually(self):
        """Manually check for updates."""
        self.statusBar().showMessage("Checking for updates...", 2000)
        self._check_for_updates()
    def clear_chat(self):
        """Clear chat history with confirmation."""
        reply = QMessageBox.question(
            self, 'Clear Chat',
            'Are you sure you want to clear the chat history?',
            QMessageBox.Yes | QMessageBox.No, QMessageBox.No
        )
        if reply == QMessageBox.Yes:
            self.chat_display.clear()
            self.statusBar().showMessage('Chat history cleared', 2000)

    def save_chat(self):
        """Save chat history to a text file using file dialog."""
        from datetime import datetime
        try:
            # Create default filename with timestamp
            default_name = f"chat_history_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            
            # Open file dialog
            filename, _ = QFileDialog.getSaveFileName(
                self,
                "Save Chat History",
                default_name,
                "Text Files (*.txt);;All Files (*)"
            )
            
            if filename:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(self.chat_display.toPlainText())
                self.statusBar().showMessage(f'Chat saved to {filename}', 2000)
        except Exception as e:
            QMessageBox.warning(self, 'Save Error', 
                f'Failed to save chat:\n\n{str(e)}')

    def open_saved_chat(self):
        """Open a previously saved chat file."""
        try:
            # Open file dialog
            filename, _ = QFileDialog.getOpenFileName(
                self,
                "Open Saved Chat",
                "",
                "Text Files (*.txt);;All Files (*)"
            )
            
            if filename:
                # Confirm if current chat should be replaced
                if self.chat_display.toPlainText().strip():
                    reply = QMessageBox.question(
                        self,
                        'Open Chat',
                        'This will replace your current chat history. Continue?',
                        QMessageBox.Yes | QMessageBox.No,
                        QMessageBox.No
                    )
                    if reply == QMessageBox.No:
                        return
                
                # Read and display the file
                with open(filename, 'r', encoding='utf-8') as f:
                    self.chat_display.setText(f.read())
                self.statusBar().showMessage(f'Opened chat from {filename}', 2000)
        except Exception as e:
            QMessageBox.warning(self, 'Open Error',
                f'Failed to open chat:\n\n{str(e)}')

    def show_about_dialog(self):
        """Show about dialog."""
        QMessageBox.about(self, 'About ChatGPT Assistant',
            """<h2>ChatGPT Assistant</h2>
            <p>A native macOS application for seamless interaction with ChatGPT.</p>
            
            <p><b>Version:</b> 1.0</p>
            <p><b>Features:</b></p>
            <ul>
                <li>Real-time AI responses</li>
                <li>Context-aware conversations</li>
                <li>Secure API key storage</li>
                <li>Native macOS integration</li>
                <li>Chat history management</li>
            </ul>
            
            <p><b>Technologies:</b></p>
            <ul>
                <li>OpenAI GPT-4 API</li>
                <li>Python 3.8+</li>
                <li>PyQt6 Framework</li>
            </ul>
            
            <p><b>Security:</b></p>
            <ul>
                <li>API keys stored securely</li>
                <li>Local chat history</li>
                <li>Direct API communication</li>
            </ul>
            
            <p style="color: #666; margin-top: 20px;">
            Press F1 anytime to view this information<br>
            Use Ctrl+T to view usage tips
            </p>""")

    def _get_resource_path(self, *paths):
        """Get the correct path to a resource, whether running as script or bundle."""
        if getattr(sys, 'frozen', False):
            # Running as a bundled application
            bundle_dir = os.path.dirname(sys.executable)
            if bundle_dir.endswith('MacOS'):
                # We're inside the Mac app bundle
                resource_dir = os.path.join(os.path.dirname(bundle_dir), 'Resources')
            else:
                resource_dir = bundle_dir
        else:
            # Running as a script
            resource_dir = os.path.dirname(os.path.abspath(__file__))
        
        return os.path.join(resource_dir, *paths)

    def _get_app_version(self):
        """Get the application version from version.txt."""
        try:
            version_file = self._get_resource_path('version.txt')
            if os.path.exists(version_file):
                with open(version_file, 'r') as f:
                    return f.read().strip()
            return "1.0.0"  # Default version if file not found
        except Exception as e:
            print(f"Error reading version: {e}")  # For debugging
            return "1.0.0"  # Default version on error

    def _check_for_updates(self):
        """Start the version check process."""
        self.version_checker.start()

    def _handle_update_available(self, current_version, new_version):
        """Handle when a new version is available."""
        show_update_dialog(self, current_version, new_version)

    def show_tips_dialog(self):
        """Show usage tips dialog."""
        QMessageBox.information(self, 'Usage Tips',
            """<h3>Tips for using ChatGPT Assistant:</h3>
            
            <h4>Basic Usage:</h4>
            <ul>
                <li>Type your message and press Enter or click Send</li>
                <li>Wait for the assistant's response (watch the typing animation)</li>
                <li>The assistant remembers context within the conversation</li>
            </ul>
            
            <h4>Keyboard Shortcuts:</h4>
            <ul>
                <li>Enter - Send message</li>
                <li>Ctrl+S - Save chat history to file</li>
                <li>Ctrl+O - Open saved chat history</li>
                <li>Ctrl+L - Clear chat</li>
                <li>Ctrl+C - Copy selected text</li>
                <li>Ctrl+Shift+C - Copy entire chat</li>
                <li>Ctrl+T - Show these tips</li>
                <li>F1 - About dialog</li>
                <li>Ctrl+Q - Exit application</li>
            </ul>
            
            <h4>Additional Features:</h4>
            <ul>
                <li>Right-click in the chat window for quick actions</li>
                <li>Saved chats are stored as text files with timestamps</li>
                <li>Watch the "Processing..." indicator while waiting</li>
                <li>The assistant's responses are animated for better readability</li>
                <li>Status messages appear at the bottom of the window</li>
            </ul>
            
            <h4>Best Practices:</h4>
            <ul>
                <li>Be specific in your questions for better responses</li>
                <li>Save important conversations using Ctrl+S</li>
                <li>Clear the chat periodically for better performance</li>
                <li>Check the status bar for helpful messages</li>
            </ul>""")

def main():
    app = QApplication(sys.argv)
    
    # Set application style
    app.setStyle("Fusion")
    
    # Create and show window
    window = ChatGPTApp()
    window.create_menu()
    window.show()
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
