import logging
from dataclasses import dataclass
from typing import Any

from src.engine.acting.action import Action
from src.engine.meme import Idea
from src.components import Genesis, Hades
from src.assets.special.sound import Sound


@dataclass
class Say(Action):
    content: str
    is_internal: bool = False
    idea: Idea | None = None

    def execute(self, actor: Any, hades: Hades, genesis: Genesis):
        genesis.push(Sound(
            parent=actor,
            content=self.content,
            is_internal=self.is_internal,
            idea=self.idea,
            p=actor.p, level=actor.level,
        ))

        logging.info(f"{actor.name}: '{self.content}'")
