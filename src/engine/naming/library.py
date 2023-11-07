import logging
import random
from pathlib import Path

import toml
from ecs import Entity

from src.engine.naming.name import Name, CompositeName


def random_composite_name(sex):
    return CompositeName(random.choice(first_names[sex]), random.choice(last_names[sex]))


def _read_file(name):
    return (Path(__file__).parent / "names" / name).read_text(encoding="utf-8")

def _parse_csv(content):
    return [row.split(",") for row in content.split("\n") if row != ""]

def _interpret_name(cases):
    if "база" in cases:
        return Name.auto(cases["база"])
    return Name(cases)


first_names = {
    sex: list(map(Name, cases))
    for sex, cases in toml.loads(_read_file("first.toml")).items()
}

for sex, name, index in _parse_csv(_read_file("first.csv")):
    first_names[sex].append(Name.auto(name, int(index)))

last_names = {
    sex: list(map(Name, cases))
    for sex, cases in toml.loads(_read_file("last.toml")).items()
}

for name, index in _parse_csv(_read_file("last.csv")):
    last_names["male"].append(Name.auto(name, int(index)))
    last_names["female"].append(Name(name))

reserved_names = Entity(**
    {name: Name(cases) for name, cases in toml.loads(_read_file("reserved.toml")).items()} |
    {
        identifier: Name.auto(name, int(index))
        for identifier, name, index
        in _parse_csv(_read_file("reserved.csv"))
    }
)
