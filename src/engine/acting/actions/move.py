from src.lib.vector import add2, unsafe_set2, safe_get2, int2

from dataclasses import dataclass
from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor: OwnedEntity, level: Level, hades: Hades, genesis: Genesis):
        next_p = add2(actor.p, self.v)
        if safe_get2(level.grids.physical, next_p, object()) is not None: return

        unsafe_set2(level.grids.physical, actor.p, None)
        level.put(next_p, actor)
