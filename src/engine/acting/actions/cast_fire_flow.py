from collections import namedtuple

from src.entities.effects.fire import Fire
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.toolkit import chance
from src.lib.vector import add2, mul2, flip2, safe_get2


class CastFireFlow(namedtuple("CastFireFlowBase", "v")):
    def execute(self, actor, level, hades: Hades, genesis: Genesis):
        length = 18

        for dv in range(0, length):
            r = (length - dv) // 3 + 1
            for du in range(-r, r + 1):
                p = add2(add2(mul2(self.v, dv), mul2(flip2(self.v), du)), actor.p)

                if (
                    safe_get2(level.grids.effects, p, object()) is not None or
                    not chance((1 - dv / length) * (1 - abs(du) / r))
                ):
                    continue

                genesis.entities_to_create.append(level.put(p, Fire(half_life=18, heat=10)))
