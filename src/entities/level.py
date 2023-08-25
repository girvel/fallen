from pathlib import Path

from ecs import OwnedEntity

from src.entities.screen import Colors
from src.lib.vector import Vector, zero


class Level(OwnedEntity):
    def __init__(self):
        super().__init__(name='level_container', size=Vector(100, 100))
        self.level_grid = self.size.create_grid(None)

    def put(self, movable, p):
        p.set_in(self.level_grid, movable)
        movable.p = p
        movable.v = zero
        return movable

    palette = {
        'T': OwnedEntity(name='tree', character='T', color = Colors.Green, health=100),  # TODO reorganize to classes?
        '@': OwnedEntity(name='player_character', character='@', health=100, power=15),
    }

    def load(self, metasystem, path: Path):
        player = None

        for y, line in enumerate(path.read_text().split('\n')):
            for x, c in enumerate(line):
                if c == ".":
                    continue

                assert c in self.palette
                e = self.put(metasystem.create(**dict(self.palette[c])), Vector(x, y))
                # TODO remove **dict when reorganizing to classes

                if c == "@":
                    player = e

        return player
