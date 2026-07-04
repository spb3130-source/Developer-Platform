import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]

CONFIG_FILE = PROJECT_ROOT / "config" / "app.json"


def load_config():
    with CONFIG_FILE.open(encoding="utf-8") as file:
        return json.load(file)
