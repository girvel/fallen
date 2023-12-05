from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.lib.vector import int2, grid_set
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class Teleport(Action):
    destination: int2

    def execute(self, actor: Entity, hades: Hades, genesis: Genesis):
        grid_set(actor.level.grids["physical"], actor.p, None)
        actor.level.put(self.destination, actor)
