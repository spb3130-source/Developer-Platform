from PySide6.QtWidgets import QMainWindow

from app.app_config import load_config


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        config = load_config()

        self.setWindowTitle(config["application"]["name"])

        self.resize(1200, 700)
