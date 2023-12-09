from dataclasses import dataclass
from ecs import Entity
from src.engine.acting.action import Action
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.library.tiles.footprint import Footprint
from src.lib.query import Q
from src.lib.vector.vector import add2, int2, abs2
from src.lib.vector.grid import grid_set, grid_get


@dataclass
class Jump(Action):
    v: int2
    d: int

    def execute(self, actor: Entity, hades: Hades, genesis: Genesis):
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
            genesis.entities_to_create.add(Footprint(p=actor.p, level=actor.level))

        grid_set(actor.level.grids[actor.layer], actor.p, None)
        actor.level.put(next_p, actor)
        self.succeeded = True

