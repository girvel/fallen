from dataclasses import dataclass
from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level


@dataclass
class Leave(Action):
    def execute(self, actor: OwnedEntity, level: Level, hades: Hades, genesis: Genesis):
        if hasattr(actor, "on_death"):
            # del actor.on_death
            # TODO investigate why this causes an error
            actor.on_death = lambda *args, **kwargs: None

        hades.entities_to_destroy.add(actor)
