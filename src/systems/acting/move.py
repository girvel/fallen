from collections import namedtuple

from src.lib.vector import zero


class Move(namedtuple("MoveBase", "v")):
    def execute(self, actor, level, hades):

        next_p = actor.p + self.v
        if not (next_p >= zero) or not (next_p < level.size) or next_p.get_in(level.level_grid) is not None:
            actor.v = zero
            return

        actor.p.set_in(level.level_grid, None)
        level.put(actor, next_p)

        actor.act = None
