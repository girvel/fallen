import random
from pathlib import Path

import toml

from src.engine.name import Name, CompositeName


def _read_asset(name):
    return (Path("assets") / name).read_text(encoding="utf-8")


first_names = {sex: list(map(Name, cases)) for sex, cases in toml.loads(_read_asset("first_names.toml")).items()}
last_names  = {sex: list(map(Name, cases)) for sex, cases in toml.loads(_read_asset("last_names.toml" )).items()}


def random_composite_name(sex):
    return CompositeName(random.choice(first_names[sex]), random.choice(last_names[sex]))
