from importlib.util import spec_from_file_location, module_from_spec
from pathlib import Path

import numpy
from ecs import OwnedEntity

from src.lib.toolkit import to_camel_case


class Level(OwnedEntity):
    name = 'level_container'
    size = None
    level_grid = None

    def put(self, movable, p):
        self.level_grid[tuple(p)] = movable
        movable.p = p
        return movable

    palette = {}
    for p in Path("src/entities/generic").iterdir():
        if p.suffix != '.py': continue

        spec = spec_from_file_location(p.stem, p)
        module = module_from_spec(spec)
        spec.loader.exec_module(module)

        cls = getattr(module, to_camel_case(p.stem))
        palette[cls.character] = cls

    def load(self, metasystem, path):
        player = None

        level_lines = path.read_text().split('\n')
        self.size = numpy.array([max(len(l) for l in level_lines), len(level_lines)])
        self.level_grid = numpy.full(tuple(self.size), None)

        for y, line in enumerate(level_lines):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                assert c in self.palette
                e = self.put(metasystem.add(self.palette[c]()), numpy.array([x, y]))

                if c == "@":
                    player = e

        return player
