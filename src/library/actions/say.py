import logging
from dataclasses import dataclass
from typing import Any

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.meme import Meme, Idea
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.library.special.sound import Sound


@dataclass
class Say(Action):
    content: str
    is_internal: bool = False
    idea: Idea | None = None

    def execute(self, actor: Any, hades: Hades, genesis: Genesis):
        genesis.entities_to_create.add(Sound(
            parent=actor,
            content=self.content,
            is_internal=self.is_internal,
            idea=self.idea,
            p=actor.p, level=actor.level,
        ))

        logging.info(f"{actor.name}: '{self.content}'")
