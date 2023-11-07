import random
from pathlib import Path

import toml
from ecs import Entity

from src.engine.naming.name import Name, CompositeName


def _read_file(name):
    return (Path(__file__).parent / "names" / name).read_text(encoding="utf-8")

def _interpret_name(cases):
    if "база" in cases:
        return Name.auto(cases["база"])
    return Name(cases)


first_names = {sex: list(map(Name, cases)) for sex, cases in toml.loads(_read_file("first.toml")).items()}
last_names  = {sex: list(map(Name, cases)) for sex, cases in toml.loads(_read_file("last.toml" )).items()}
reserved_names = Entity(**
    {name: Name(cases) for name, cases in toml.loads(_read_file("reserved.toml")).items()} |
    {
        identifier: Name.auto(name, int(index))
        for identifier, name, index
        in (row.split(",") for row in _read_file("reserved.csv").split("\n"))
    }
)


def random_composite_name(sex):
    return CompositeName(random.choice(first_names[sex]), random.choice(last_names[sex]))
