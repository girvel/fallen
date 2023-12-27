from dataclasses import dataclass

from src.engine.acting.action import Action
from src.lib.query import Q
from src.lib.vector.grid import grid_get
from src.lib.vector.vector import add2, int2, abs2
from src.components import Genesis, Hades
from src.assets.special.level import Level
from src.assets.tiles.footprint import Footprint


@dataclass
class Jump(Action):
    v: int2
    d: int

    def execute(self, actor, hades: Hades, genesis: Genesis):
        if abs2(self.v) != 1:
            self.succeeded = False
            return

        next_p = actor.p

        for _ in range(self.d):
            next_p = add2(next_p, self.v)
            if grid_get(actor.level.grids[actor.layer], next_p, False) is not None:
                self.succeeded = False
                return

        if grid_get(actor.level.grids["tiles"], actor.p, False) is None and (~Q(actor).health.amount.current or 0) > 5:
            genesis.push(Footprint(p=actor.p, level=actor.level))

        Level.move(actor, next_p)
        self.succeeded = True

