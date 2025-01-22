import os
import json
import urllib.request
import urllib.error
from PyQt6.QtWidgets import QMessageBox
from PyQt6.QtCore import QThread, pyqtSignal

class VersionChecker(QThread):
    """Check for new versions of the application."""
    update_available = pyqtSignal(str, str)  # current_version, new_version
    check_complete = pyqtSignal(bool)  # updates_available
    
    def __init__(self, current_version, parent=None):
        super().__init__(parent)
        self.current_version = current_version
        self.update_url = "https://api.github.com/repos/YOUR_REPO/releases/latest"
        self.manual_check = False
    
    def check_for_updates(self, manual=False):
        """Start checking for updates."""
        self.manual_check = manual
        self.start()
        
    def run(self):
        try:
            # Get current version from version.txt
            if not self.current_version:
                version_file = os.path.join(
                    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                    "Resources", "version.txt"
                )
                if os.path.exists(version_file):
                    with open(version_file, 'r') as f:
                        self.current_version = f.read().strip()
                else:
                    self.current_version = "1.0.0"
            
            # Check for updates
            try:
                with urllib.request.urlopen(self.update_url, timeout=5) as response:
                    data = json.loads(response.read())
                    latest_version = data['tag_name'].lstrip('v')
                    
                    # Compare versions
                    has_update = self._compare_versions(latest_version, self.current_version) > 0
                    if has_update:
                        self.update_available.emit(self.current_version, latest_version)
                    elif self.manual_check:
                        QMessageBox.information(
                            None,
                            "No Updates Available",
                            f"You're running the latest version ({self.current_version})."
                        )
                    self.check_complete.emit(has_update)
                    
            except urllib.error.URLError as e:
                if self.manual_check:
                    QMessageBox.warning(
                        None,
                        "Connection Error",
                        "Could not check for updates.\nPlease check your internet connection."
                    )
                self.check_complete.emit(False)
                
        except Exception as e:
            # Log error but don't disrupt the application
            print(f"Error checking for updates: {str(e)}")
    
    def _compare_versions(self, version1, version2):
        """Compare two version strings."""
        v1_parts = [int(x) for x in version1.split('.')]
        v2_parts = [int(x) for x in version2.split('.')]
        
        for i in range(max(len(v1_parts), len(v2_parts))):
            v1 = v1_parts[i] if i < len(v1_parts) else 0
            v2 = v2_parts[i] if i < len(v2_parts) else 0
            
            if v1 > v2:
                return 1
            elif v1 < v2:
                return -1
        return 0

def show_update_dialog(parent, current_version, new_version):
    """Show update available dialog."""
    msg = QMessageBox(parent)
    msg.setIcon(QMessageBox.Icon.Information)
    msg.setWindowTitle("Update Available")
    msg.setText(f"A new version of ChatGPT Assistant is available!")
    msg.setInformativeText(
        f"Current version: {current_version}\n"
        f"New version: {new_version}\n\n"
        f"Would you like to download the update?"
    )
    msg.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
    msg.setDefaultButton(QMessageBox.Yes)
    
    if msg.exec() == QMessageBox.Yes:
        # Open download URL in default browser
        import webbrowser
        webbrowser.open("https://github.com/YOUR_REPO/releases/latest")
