from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.entities.effects.fire import Fire
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.toolkit import chance
from src.lib.vector import add2, mul2, flip2, grid_get, int2


@dataclass
class CastFireFlow(Action):
    v: int2

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis) -> object:
        length = 18

        for dv in range(0, length):
            r = (length - dv) // 3 + 1
            for du in range(-r, r + 1):
                p = add2(add2(mul2(self.v, dv), mul2(flip2(self.v), du)), actor.p)

                if (
                    grid_get(actor.level.grids.effects, p, object()) is not None or
                    not chance((1 - dv / length) * (1 - abs(du) / r))
                ):
                    continue

                genesis.entities_to_create.add(Fire(half_life=18, heat=10, p=p, level=actor.level))
