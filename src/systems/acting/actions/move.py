from collections import namedtuple

from src.lib.vector import zero, add2, unsafe_set2, safe_get2


class Move(namedtuple("MoveBase", "v")):
    def execute(self, actor, level, hades):
        next_p = add2(actor.p, self.v)
        if safe_get2(level.physical_grid, next_p) is not None:
            actor.v = zero
            return

        unsafe_set2(level.physical_grid, actor.p, None)
        level.put(next_p, actor)
