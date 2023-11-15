from dataclasses import dataclass
from ecs import DynamicEntity
from src.engine.acting.action import Action
from src.engine.acting.damage import ArmorKind, inflict_damage, DamageKind
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.lib.query import Q
from src.lib.toolkit import chance
from src.lib.vector import grid_get, int2, add2, mul2, flip2


@dataclass
class CastStoneStomp(Action):
    v: int2

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        length = 13
        for dv in range(0, length):
            for du in range(-dv, dv + 1):
                if chance(.05): continue

                p = add2(add2(mul2(self.v, dv), mul2(flip2(self.v), du)), actor.p)

                wall = grid_get(actor.level.grids.physical, p, object())
                if ~Q(wall).health.armor_kind == ArmorKind.Stone:
                    inflict_damage(wall, 7_500, DamageKind.Crushing, hades, actor)
