import logging
from dataclasses import dataclass, field
from typing import Optional

from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.entities.special.sound import Sound


@dataclass
class Say(Action):
    content: str
    target: Optional[OwnedEntity] = field(default=None)

    def execute(self, actor: OwnedEntity, level: Level, hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(level.put(actor.p, Sound(self.content, self.target)))
        logging.info(f"{actor.name} says to {self.target.name}: '{self.content}'")
