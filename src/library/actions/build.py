from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.acting.typing import EntityFactory
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.lib.vector.vector import int2
from src.lib.vector.grid import grid_get


@dataclass
class Build(Action):
    p: int2
    entity_factory: EntityFactory

    def execute(self, actor, hades: Hades, genesis: Genesis):
        if grid_get(actor.level.grids["physical"], self.p) is not None: return
        genesis.push(self.entity_factory(p=self.p, level=actor.level))
