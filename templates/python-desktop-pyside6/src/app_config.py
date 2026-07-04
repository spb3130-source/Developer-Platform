import json
from pathlib import Path

CONFIG_FILE = Path(__file__).parent.parent / "config" / "app.json"


def load_config():
    with CONFIG_FILE.open(encoding="utf-8") as file:
        return json.load(file)
