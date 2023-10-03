import logging

from src.lib.vector import add2, grid_set, grid_get, int2

from dataclasses import dataclass
from ecs import DynamicEntity
from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor: DynamicEntity, level: Level, hades: Hades, genesis: Genesis):
        next_p = add2(actor.p, self.v)
        logging.debug(next_p)
        if grid_get(level.grids.physical, next_p, object()) is not None: return

        grid_set(level.grids.physical, actor.p, None)
        level.put(next_p, actor)
