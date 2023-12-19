from dataclasses import dataclass

from src.components import Genesis, Hades
from src.engine.acting.action import Action
from src.lib.query import Q
from src.lib.vector.grid import grid_get
from src.lib.vector.vector import add2, int2, abs2
from src.library.special.level import Level
from src.library.tiles.footprint import Footprint


@dataclass
class Move(Action):
    v: int2

    def execute(self, actor, hades: Hades, genesis: Genesis):
        if abs2(self.v) != 1 or actor.layer != "physical":
            self.succeeded = False
            return

        next_p = add2(actor.p, self.v)
        if grid_get(actor.level.grids["physical"], next_p, False) is not None:
            self.succeeded = False
            return

        if grid_get(actor.level.grids["tiles"], actor.p, False) is None and (~Q(actor).health.amount.maximum or 0) > 5:
            genesis.push(Footprint(p=actor.p, level=actor.level))

        Level.move(actor, next_p)
