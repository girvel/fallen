import logging
from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.vector import add2, grid_set, grid_get, int2


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        next_p = add2(actor.p, self.v)
        if grid_get(actor.level.grids[actor.layer], next_p, object()) is not None: return

        grid_set(actor.level.grids[actor.layer], actor.p, None)
        actor.level.put(next_p, actor)
