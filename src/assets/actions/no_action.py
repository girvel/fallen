from dataclasses import dataclass
from ecs import Entity
from src.engine.acting.action import Action
from src.components import Genesis, Hades


@dataclass
class NoAction(Action):
    def execute(self, actor, hades: Hades, genesis: Genesis):
        pass
