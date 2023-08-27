import logging
from pathlib import Path

from ecs import OwnedEntity

from src.lib.toolkit import load_palette_from
from src.lib.vector import unsafe_set, create_grid

log = logging.getLogger(__name__)


class Level(OwnedEntity):
    name = 'level_container'
    size = None
    physical_grid = None
    tile_grid = None
    effects_grid = None

    def put(self, movable, p):  # TODO 3d stuff?
        unsafe_set(self.physical_grid, p, movable)
        movable.p = p
        return movable

    physical_palette = load_palette_from(Path("src/entities/generic"))
    tile_palette = load_palette_from(Path("src/entities/tiles"))

    def load(self, metasystem, path: Path):
        player = None

        level_lines = path.read_text().split('\n')
        self.size = (max(len(l) for l in level_lines), len(level_lines))
        self.physical_grid = create_grid(self.size, lambda: None)
        self.tile_grid = create_grid(self.size, lambda: None)
        self.effects_grid = create_grid(self.size, lambda: None)

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                if c in self.physical_palette:
                    e = self.put(metasystem.add(self.physical_palette[c]()), (x, y))

                    if c == "@":
                        player = e
                elif c in self.tile_palette:
                    unsafe_set(self.tile_grid, (x, y), metasystem.add(self.tile_palette[c]()))
                else:
                    log.warning(f"Ignored unknown entity `{c}` at {(x, y)}")

        return player
