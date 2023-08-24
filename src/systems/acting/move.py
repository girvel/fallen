from collections import namedtuple

from src.lib.vector import zero


class Move(namedtuple("MoveBase", "v")):
    def execute(self, movable, level, hades):
        next_p = movable.p + self.v
        if not (next_p >= zero) or not (next_p < level.size) or next_p.get_in(level.level_grid) is not None:
            movable.v = zero
            return

        movable.p.set_in(level.level_grid, None)
        level.put(movable, next_p)
