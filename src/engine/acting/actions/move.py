from collections import namedtuple

from src.lib.vector import add2, unsafe_set2, safe_get2


class Move(namedtuple("MoveBase", "v")):
    def execute(self, actor, level, hades, genesis):
        next_p = add2(actor.p, self.v)
        if safe_get2(level.grids.physical, next_p, object()) is not None: return

        unsafe_set2(level.grids.physical, actor.p, None)
        level.put(next_p, actor)
