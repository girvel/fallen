import logging
import os
import sys
from pathlib import Path

import toml

file_path: Path

if sys.platform.startswith("win"):
    file_path = os.getenv("APPDATA") / Path(f"fallen/permanent_storage.toml")
else:
    file_path = os.getenv("HOME") / Path(".local/share/fallen/permanent_storage.toml")


def initialize():
    try:
        file_path.parent.mkdir(parents=True, exist_ok=True)
    except Exception as ex:
        logging.warning(f"Unable to create permanent storage directory {file_path}", exc_info=ex)
        directory = None


def _read_storage():
    return toml.loads(file_path.read_text(encoding="utf-8")) if file_path.exists() else {}


def read_key(key: str, default = None):
    try:
        return _read_storage().get(key, default)
    except Exception as ex:
        logging.warning(f"Error when reading from permanent storage: {key=}", exc_info=ex)
        return default


def write_key(key: str, value):
    try:
        content = _read_storage()
        content[key] = value
        file_path.write_text(toml.dumps(content), encoding="utf-8")
        return True
    except Exception as ex:
        logging.warning(f"Error when writing to permanent storage: {key=}, {value=}", exc_info=ex)
        return False
