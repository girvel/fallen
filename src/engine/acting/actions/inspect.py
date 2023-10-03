from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades


@dataclass
class Inspect(Action):
    subject: DynamicEntity

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        pass
