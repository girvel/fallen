import logging
from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path
from typing import TypeVar, Callable

import toml as toml
from ecs import DynamicEntity, Entity
from rust_enum import Option

from src.entities.markup.house import House
from src.entities.markup.zone import Zone
from src.lib.toolkit import to_camel_case, import_module
from src.lib.vector import grid_set, create_grid, int2


def load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        cls = getattr(import_module(p), to_camel_case(p.stem))
        result[cls.character] = cls

    return result

class Level(DynamicEntity):
    name = 'level_container'

    T = TypeVar('T')
    def put(self, p: int2, entity: T) -> T:
        grid_set(self.grids[entity.layer], p, entity)
        entity.p = p
        return entity

    layers = ["tiles", "physical", "effects", "sounds"]
    invisible_layers = {"sounds"}

    markup = None
    player = None

    def __init__(self, ms, path: Path, io):
        level_lines = (path / "grid.txt").read_text().split('\n')
        size = (max(len(l) for l in level_lines), len(level_lines))

        after_loads = []

        self.grids = Entity(**{l: create_grid(size, lambda: None) for l in self.layers})
        self.palettes = Entity(**{
            l: load_palette_from(Path("src/entities") / l)
            for l in self.layers
            if l not in self.invisible_layers
        })

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                for layer, palette in self.palettes:
                    if c not in palette: continue

                    e = ms.add(palette[c]())
                    e.layer = layer
                    self.put((x, y), e)

                    if "after_load" in e:
                        after_loads.append(e.after_load)

                    if c == "@":
                        self.player = e
                        e.ai = io
                    break
                else:
                    logging.warning(f"Ignored unknown entity `{c}` at {(x, y)}")

        raw_markup = toml.loads((path / "markup.toml").read_text())
        self.markup = Entity(
            houses=[ms.add(House(**h)) for h in raw_markup["houses"]],
            zones=[ms.add(Zone(**h)) for h in raw_markup["zones"]],
        )

        for after_load in after_loads:
            after_load(self)

        rails_path = path / "rails.py"
        if rails_path.exists():
            ms.add(import_module(rails_path).Rails(self))

        self.rails_effect = {}

    def query(self, request: Callable[[DynamicEntity], bool]) -> Option[DynamicEntity]:
        return next((  # TODO Option.next?
            Option.Some(e)
            for _, layer in self.grids
            for row in layer[0]
            for e in row
            if e and request(e)
        ), Option.Nothing())
