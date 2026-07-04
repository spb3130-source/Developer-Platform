from pathlib import Path

from loguru import logger

LOG_DIRECTORY = Path("logs")
LOG_DIRECTORY.mkdir(exist_ok=True)

logger.remove()

logger.add(
    LOG_DIRECTORY / "application.log",
    level="INFO",
    rotation="10 MB",
    retention="30 days",
    enqueue=True,
)

logger.add(
    sink=lambda message: print(message, end=""),
    level="INFO",
)

app_logger = logger
