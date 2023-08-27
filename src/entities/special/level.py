import logging
from pathlib import Path

from ecs import OwnedEntity

from src.lib.toolkit import load_palette_from
from src.lib.vector import unsafe_set2, create_grid

log = logging.getLogger(__name__)


class Level(OwnedEntity):
    name = 'level_container'
    size = None

    tile_grid = None
    physical_grid = None
    effect_grid = None

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

    def load(self, metasystem, path: Path):
        player = None

        level_lines = path.read_text().split('\n')
        self.size = (max(len(l) for l in level_lines), len(level_lines))  # TODO move to size2(physical_grid)

        self.tile_grid = create_grid(self.size, lambda: None)
        self.physical_grid = create_grid(self.size, lambda: None)
        self.effect_grid = create_grid(self.size, lambda: None)

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
                        if c == "@":
                            player = e
                        break
                else:
                    log.warning(f"Ignored unknown entity `{c}` at {(x, y)}")

        return player
