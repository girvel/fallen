import logging
from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.tiles.footprint import Footprint
from src.lib.query import Q
from src.lib.vector import add2, grid_set, grid_get, int2, abs2


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        if abs2(self.v) != 1:
            self.succeeded = False
            return

        next_p = add2(actor.p, self.v)
        if grid_get(actor.level.grids[actor.layer], next_p, False) is not None:
            self.succeeded = False
            return

        if grid_get(actor.level.grids.tiles, actor.p, False) is None and (~Q(actor).health.amount.maximum or 0) > 5:
            genesis.entities_to_create.add(Footprint(p=actor.p, level=actor.level))

        grid_set(actor.level.grids[actor.layer], actor.p, None)
        actor.level.put(next_p, actor)
