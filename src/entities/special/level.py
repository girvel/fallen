import logging
from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path

import toml as toml
from ecs import OwnedEntity, Entity

from src.entities.markup.house import House
from src.entities.markup.zone import Zone
from src.lib.toolkit import to_camel_case
from src.lib.vector import unsafe_set2, create_grid



def load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        spec = spec_from_file_location(p.stem, p)
        module = module_from_spec(spec)
        spec.loader.exec_module(module)

        cls = getattr(module, to_camel_case(p.stem))
        result[cls.character] = cls

    return result

class Level(OwnedEntity):
    name = 'level_container'

    def put(self, p, entity):
        unsafe_set2(self.grids[entity.layer], p, entity)
        entity.p = p
        return entity

    layers = ["tiles", "physical", "effects"]
    palettes = Entity(**{
        l: load_palette_from(Path("src/entities") / l) for l in layers
    })

    markup = None

    def __init__(self, ms, path: Path, io):
        player = None

        level_lines = (path / "grid.txt").read_text().split('\n')
        size = (max(len(l) for l in level_lines), len(level_lines))

        after_loads = []

        self.grids = Entity(**{l: create_grid(size, lambda: None) for l in self.layers})

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