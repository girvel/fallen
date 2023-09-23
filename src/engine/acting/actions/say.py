import logging
from dataclasses import dataclass

from ecs import OwnedEntity

from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.entities.special.sound import Sound


@dataclass
class Say(Action):
    content: str
    is_internal: bool = False

    def execute(self, actor: OwnedEntity, level: Level, hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(Sound(self.content, self.is_internal, actor.p))
        logging.info(f"{actor.name} says '{self.content}'")
