from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class Inspect(Action):
    subject: Entity

    def execute(self, actor, hades: Hades, genesis: Genesis):
        pass
