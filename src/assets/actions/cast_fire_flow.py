from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.assets.effects.fire import Fire
from src.components import Genesis, Hades
from src.lib.toolkit import chance
from src.lib.vector.vector import add2, mul2, flip2, int2
from src.lib.vector.grid import grid_get


@dataclass
class CastFireFlow(Aggressive, Action):
    v: int2
    length: int = 18

    def execute(self, actor, hades: Hades, genesis: Genesis) -> None:
        for dp, k in self._pattern():
            p = add2(dp, actor.p)

            if grid_get(actor.level.grids["effects"], p, object()) is not None or not chance(k):
                continue

            genesis.push(Fire(half_life=18, heat=10, p=p, level=actor.level, parent=actor))

    def _pattern(self):
        for dv in range(0, self.length):
            r = (self.length - dv) // 3 + 1
            for du in range(-r, r + 1):
                yield (
                    add2(mul2(self.v, dv), mul2(flip2(self.v), du)),
                    (1 - dv / self.length) * (1 - abs(du) / r)
                )

    def get_victims(self, actor) -> list[Entity]:
        return [
            victim
            for dp, _ in self._pattern()
            if (victim := grid_get(actor.level.grids["physical"], add2(actor.p, dp))) is not None
        ]
