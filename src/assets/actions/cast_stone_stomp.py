from dataclasses import dataclass
from ecs import Entity
from src.engine.acting.action import Action
from src.engine.acting.damage import inflict_damage
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.components import Genesis, Hades
from src.lib.query import Q
from src.lib.toolkit import chance
from src.lib.vector.vector import int2, add2, mul2, flip2
from src.lib.vector.grid import grid_get


@dataclass
class CastStoneStomp(Action):
    v: int2

    def execute(self, actor, hades: Hades, genesis: Genesis):
        length = 13
        for dv in range(0, length):
            for du in range(-dv, dv + 1):
                if chance(.05): continue

                p = add2(add2(mul2(self.v, dv), mul2(flip2(self.v), du)), actor.p)

                target = grid_get(actor.level.grids["physical"], p, object())
                if hasattr(target, "hard_flag"):
                    inflict_damage(actor, target, 7_500, hades)
