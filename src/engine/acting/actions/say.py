import logging
from dataclasses import dataclass, field

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.meme import Meme
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.sound import Sound


@dataclass
class Say(Action):
    content: str
    is_internal: bool = False
    meme: Meme = field(default_factory=Meme.Nothing)

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(Sound(
            self.content, self.is_internal, self.meme, p=actor.p, level=actor.level
        ))

        logging.info(f"{actor.name} says '{self.content}'")
