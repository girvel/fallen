from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.lib.vector.vector import int2
from src.lib.vector.grid import grid_set
from src.components import Genesis, Hades
from src.assets.special.level import Level


@dataclass
class Teleport(Action):
    destination: int2

    def execute(self, actor, hades: Hades, genesis: Genesis):
        Level.move(actor, self.destination)
