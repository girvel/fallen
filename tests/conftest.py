from pathlib import Path

import pytest


@pytest.fixture(autouse=True)
def reset_working_directory(monkeypatch):
    monkeypatch.chdir(Path(__file__).parents[1])
