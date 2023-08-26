from collections import namedtuple

from src.lib.vector import zero, add, unsafe_set, safe_get


class Move(namedtuple("MoveBase", "v")):
    def execute(self, actor, level, hades):
        next_p = add(actor.p, self.v)
        if safe_get(level.physical_grid, next_p) is not None:
            actor.v = zero
            return

        unsafe_set(level.physical_grid, actor.p, None)
        level.put(actor, next_p)

        actor.act = None
