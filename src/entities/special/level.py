import logging
from pathlib import Path

import toml as toml
from ecs import OwnedEntity, Entity

from src.entities.markup.house import House
from src.entities.markup.zone import Zone
from src.lib.toolkit import load_palette_from
from src.lib.vector import unsafe_set2, create_grid

log = logging.getLogger(__name__)


class Level(OwnedEntity):
    name = 'level_container'

    def put_tile(self, p, tile):
        unsafe_set2(self.tile_grid, p, tile)
        tile.tile_p = p
        return tile

    def put(self, p, movable):
        unsafe_set2(self.physical_grid, p, movable)
        movable.p = p
        return movable

    def put_effect(self, p, effect):
        unsafe_set2(self.effect_grid, p, effect)
        effect.effect_p = p
        return effect

    tile_palette = load_palette_from(Path("src/entities/tiles"))
    physical_palette = load_palette_from(Path("src/entities/physical"))
    effect_palette = load_palette_from(Path("src/entities/effects"))
    markup = None

    def __init__(self, metasystem, path: Path):
        player = None

        level_lines = (path / "grid.txt").read_text().split('\n')
        size = (max(len(l) for l in level_lines), len(level_lines))

        after_loads = []

        self.tile_grid = create_grid(size, lambda: None)
        self.physical_grid = create_grid(size, lambda: None)
        self.effect_grid = create_grid(size, lambda: None)

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                for palette, put in (
                    (self.physical_palette, self.put),
                    (self.tile_palette, self.put_tile),
                    (self.effect_palette, self.put_effect),
                ):
                    if c in palette:
                        e = put((x, y), metasystem.add(palette[c]()))
                        if "after_load" in e:
                            after_loads.append(e.after_load)

                        if c == "@":
                            self.player = e
                        break
                else:
                    log.warning(f"Ignored unknown entity `{c}` at {(x, y)}")

        raw_markup = toml.loads((path / "markup.toml").read_text())
        self.markup = Entity(
            houses=[metasystem.add(House(**h)) for h in raw_markup["houses"]],
            zones=[metasystem.add(Zone(**h)) for h in raw_markup["zones"]],
        )

        for after_load in after_loads:
            after_load(self)
