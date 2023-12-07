import logging
from dataclasses import dataclass
from functools import reduce
from pathlib import Path
from typing import TypeVar, Callable, Type, Iterator, Any

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


def load_toml(path: Path):
    return toml.loads(path.read_text(encoding="utf-8")) if path.exists() else {}


@dataclass
class Markup:
    zones: list[Zone]
    houses: list[House]

@dataclass(init=False)
class GridArgs:
    entries: dict[int2, dict[str, Any]]

    def __init__(self, entries=None):
        self.entries = {
            tuple(entry["at"]): entry["args"]
            for entry in entries or []
        }

@dataclass
class Config:
    prep_ticks: int = 0


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

        grid_args = GridArgs(**load_toml(path / "grid_args.toml"))  # TODO maybe join w/ markup?
        self.config = Config(**load_toml(path / "config.toml"))

        self.size = (max(len(line) for line in level_lines), len(level_lines))

        after_loads = []

        self.grids = {layer: create_grid(self.size, lambda: None) for layer in self.layers}
        self.palette = reduce(lambda a, b: a | b, (
            load_palette_from(Path("src/library") / layer)
            for layer in self.layers
            if layer not in self.invisible_layers
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
                    e = ms.add(self.palette[c](p=p, level=self, **grid_args.entries.get(p, {})))
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

        # rails_path = path / "rails.py"
        # self.rails = import_module(rails_path).Rails(self, ms, genesis) if rails_path.exists() else None
        self.rails = None

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
        return self.query(lambda e: isinstance(e, entity_type))

    def iter_square(self, p: int2, r: int):  # TODO should be together with rhombus_iterator
        for y in range(max(0, p[1] - r), min(self.size[1], p[1] + r + 1)):
            for x in range(max(0, p[0] - r), min(self.size[0], p[0] + r + 1)):
                yield x, y
