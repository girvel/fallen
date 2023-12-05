import logging
from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.library.tiles.footprint import Footprint
from src.lib.query import Q
from src.lib.vector import add2, grid_set, grid_get, int2, abs2


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor: Entity, hades: Hades, genesis: Genesis):
        if abs2(self.v) != 1 or actor.layer != "physical":
            self.succeeded = False
            return

        next_p = add2(actor.p, self.v)
        if grid_get(actor.level.grids["physical"], next_p, False) is not None:
            self.succeeded = False
            return

        if grid_get(actor.level.grids["tiles"], actor.p, False) is None and (~Q(actor).health.amount.maximum or 0) > 5:
            genesis.entities_to_create.add(Footprint(p=actor.p, level=actor.level))

        grid_set(actor.level.grids["physical"], actor.p, None)
        actor.level.put(next_p, actor)
