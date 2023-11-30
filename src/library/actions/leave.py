from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class Leave(Action):
    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        if hasattr(actor, "on_death"):
            del actor.on_death
            # TODO investigate why this causes an error
            # actor.on_death = lambda *args, **kwargs: True

        hades.entities_to_destroy.add(actor)
