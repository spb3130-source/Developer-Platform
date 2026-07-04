from config import load_config
from PySide6.QtWidgets import QMainWindow


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        config = load_config()

        self.setWindowTitle(config["application"]["name"])

        self.resize(1200, 700)
