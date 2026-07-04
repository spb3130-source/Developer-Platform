import sys

from PySide6.QtWidgets import QApplication

from logger import app_logger
from views.main_window import MainWindow


class Application:
    """Application bootstrap."""

    def __init__(self) -> None:
        self.qt_app = QApplication(sys.argv)
        self.main_window = MainWindow()
        app_logger.info("Application starting...")

    def run(self) -> int:
        self.main_window.show()
        return self.qt_app.exec()
        app_logger.info("Application running...")
