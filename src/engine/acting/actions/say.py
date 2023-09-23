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

    def execute(self, actor: OwnedEntity, level: Level, hades: Hades, genesis: Genesis):
        sound = Sound(self.content)
        sound.p = actor.p  # TODO Entity | dict
        genesis.entities_to_create.add(sound)
        logging.info(f"{actor.name} says '{self.content}'")
