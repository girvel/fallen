from pathlib import Path

import yaml

assets_folder = Path("assets")

names = yaml.safe_load((assets_folder / "names.yaml").read_text())
strange_names = yaml.safe_load((assets_folder / "strange_names.yaml").read_text())
