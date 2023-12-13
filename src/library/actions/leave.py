from dataclasses import dataclass

from src.engine.acting.action import Action
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class Leave(Action):
    def execute(self, actor, hades: Hades, genesis: Genesis):
        if hasattr(actor, "on_death"):
            actor.on_death = lambda *_, **__: False

        hades.entities_to_destroy.add(actor)
