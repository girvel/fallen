from dataclasses import dataclass

from src.engine.acting.action import Action
from src.components import Genesis, Hades


@dataclass
class Leave(Action):
    def execute(self, actor, hades: Hades, genesis: Genesis):
        if hasattr(actor, "on_destruction"):
            actor.on_destruction = lambda *_, **__: False

        hades.push(actor)
