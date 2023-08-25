from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path

from ecs import OwnedEntity

from src.entities.generic.bush import Bush
from src.entities.generic.player import Player
from src.entities.generic.slash_wall import SlashWall
from src.entities.generic.thick_wall import ThickWall
from src.entities.generic.tree import Tree
from src.entities.generic.water import Water
from src.lib.toolkit import to_camel_case
from src.lib.vector import Vector, zero


class Level(OwnedEntity):
    name = 'level_container'
    size = None
    level_grid = None

    def put(self, movable, p):
        p.set_in(self.level_grid, movable)
        movable.p = p
        movable.v = zero
        return movable

    palette = {}
    for p in Path("src/entities/generic").iterdir():
        if p.suffix != '.py': continue

        spec = spec_from_file_location(p.stem, p)
        module = module_from_spec(spec)
        spec.loader.exec_module(module)

        cls = getattr(module, to_camel_case(p.stem))
        palette[cls.character] = cls

    def load(self, metasystem, path: Path):
        player = None

        level_lines = path.read_text().split('\n')
        self.size = Vector(max(len(l) for l in level_lines), len(level_lines))
        self.level_grid = self.size.create_grid(None)

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                assert c in self.palette
                e = self.put(metasystem.add(self.palette[c]()), Vector(x, y))

                if c == "@":
                    player = e

        return player
