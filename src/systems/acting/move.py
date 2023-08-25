from collections import namedtuple

from src.lib.vector import zero, safe_get


class Move(namedtuple("MoveBase", "v")):
    def execute(self, actor, level, hades):
        next_p = actor.p + self.v
        if not (next_p >= zero).all() or not (next_p < level.size).all() or safe_get(level.level_grid, next_p) is not None:
            actor.v = zero
            return

        level.level_grid[tuple(actor.p)] = None
        level.put(actor, next_p)

        actor.act = None
