import logging
from dataclasses import dataclass
from functools import reduce
from pathlib import Path
from typing import TypeVar, Callable, Type, Iterator

import numpy
import toml as toml
from ecs import Entity, MetasystemFacade

from src.engine.language.name import Name
from src.lib.toolkit import to_camel_case, import_module
from src.lib.vector import grid_set, create_grid, int2
from src.library.markup.house import House
from src.library.markup.zone import Zone
from src.library.special.genesis import Genesis


def load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        cls = getattr(import_module(p), to_camel_case(p.stem))
        result[cls.character] = cls

    return result


def load_special_arguments(path):
    return {
        tuple(entry["at"]): entry["args"]
        for entry in toml.loads(path.read_text())["entries"]
    } if path.exists() else {}


@dataclass
class Markup:
    zones: list[Zone]
    houses: list[House]


T = TypeVar('T')

class Level(Entity):
    name = Name("Уровень")
    no_entity_character = "."

    def put(self, p: int2, entity: T) -> T:
        grid_set(self.grids[entity.layer], p, entity)
        entity.p = p
        entity.level = self
        return entity

    @staticmethod
    def change(entity: T, target: "Level", p: int2) -> T:
        grid_set(entity.level.grids[entity.layer], entity.p, None)
        entity.level = target
        target.put(p, entity)

    layers = ["tiles", "physical", "effects", "sounds"]
    invisible_layers = {"sounds"}  # TODO maybe as a separate thing instead of subset?

    markup = None
    player = None

    def __init__(self, ms: MetasystemFacade, path: Path, no_rails: bool, genesis: Genesis):
        level_lines = (path / "grid.txt").read_text().split('\n')
        special_arguments = load_special_arguments(path / "grid_args.toml")

        self.size = (max(len(l) for l in level_lines), len(level_lines))

        after_loads = []

        self.grids = {l: create_grid(self.size, lambda: None) for l in self.layers}
        self.palette = reduce(lambda a, b: a | b, (
            load_palette_from(Path("src/library") / l)
            for l in self.layers
            if l not in self.invisible_layers
        ))

        for layer in self.layers:
            if layer in self.invisible_layers: continue

            local_palette_path = path / "library" / layer
            if local_palette_path.exists():
                self.palette.update(load_palette_from(local_palette_path))

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                p = (x, y)

                if c == Level.no_entity_character:
                    continue

                if c in self.palette:
                    e = ms.add(self.palette[c](p=p, level=self, **special_arguments.get(p, {})))
                    self.put(p, e)

                    if hasattr(e, "after_load"):
                        after_loads.append(e.after_load)
                else:
                    logging.warning(f"Ignored unknown entity `{c}` at {p}")

        markup_path = path / "markup.toml"
        if markup_path.exists():
            raw_markup = toml.loads(markup_path.read_text(encoding="utf-8"))
            self.markup = Markup(
                houses=[ms.add(House.from_markup(**h)) for h in raw_markup["houses"]],
                zones=[ms.add(Zone.from_markup(**h)) for h in raw_markup["zones"]],
            )
        else:
            self.markup = Markup(houses=[], zones=[])

        for after_load in after_loads:
            after_load(self)

        # TODO NEXT rails
        # if not no_rails:
        if False:
            rails_path = path / "rails.py"
            if rails_path.exists():
                self.rails = import_module(rails_path).Rails(self, ms, genesis)

        self.rails_effect = {}

        self.transparency_cache = numpy.full(self.size, 1)

    def query(self, request: Callable[[Entity], bool]) -> Iterator[Entity]:
        return (
            e
            for _, layer in self.grids.items()
            for row in layer[0]
            for e in row
            if e and request(e)
        )

    def find(self, entity_type: Type[T]) -> Iterator[T]:
        return self.query(lambda e: e.character == entity_type.character)

    def iter_square(self, p: int2, r: int):
        for y in range(max(0, p[1] - r), min(self.size[1], p[1] + r + 1)):
            for x in range(max(0, p[0] - r), min(self.size[0], p[0] + r + 1)):
                yield x, y
