import logging
import random
from pathlib import Path
from typing import Literal

import toml
from ecs import Entity

from src.engine.naming.name import Name, CompositeName


def random_composite_name(sex):
    return CompositeName(random.choice(first_names[sex]), random.choice(last_names)[sex])


def _read_file(name):
    return (Path(__file__).parent / "names" / name).read_text(encoding="utf-8")

def _parse_csv(content):
    return [row.split(",") for row in content.split("\n") if row != ""]

def _interpret_name(cases):
    if "база" in cases:
        return Name.auto(cases["база"])
    return Name(cases)


Sex = Literal["male", "female"]

first_names: dict[Sex, list[Name]] = {
    sex: list(map(Name, cases))
    for sex, cases in toml.loads(_read_file("first.toml")).items()
}

for sex, name, index in _parse_csv(_read_file("first.csv")):
    first_names[sex].append(Name.auto(name, int(index)))

last_names: list[dict[Sex, Name]] = [
    {sex: Name(cases) for sex, cases in name.items()}
    for name in toml.loads(_read_file("last.toml"))["names"]
] + [
    {
        "male": Name.auto(name, int(index)),
        "female": Name(name),
    }
    for name, index in _parse_csv(_read_file("last.csv"))
]

reserved_names = Entity(**
    {
        identifier: {sex: Name(cases) for sex, cases in name.items()}
        for identifier, name
        in toml.loads(_read_file("reserved.toml")).items()
    } | {
        identifier: Name.auto(name, int(index))
        for identifier, name, index
        in _parse_csv(_read_file("reserved.csv"))
    }
)
