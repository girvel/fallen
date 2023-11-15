from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.meme import Aggression, Idea
from src.lib.query import Q
from src.library.actions.attack import Attack
from src.systems.ai import Perception


@dataclass
class Observer:
    def use(self, subject: DynamicEntity, perception: Perception) -> list[tuple[DynamicEntity, int]]:
        memes = []

        aggressions = [
            Aggression(e, target)
            for e in perception.vision.physical.values()
            if (target := ~Q(e).act[Attack].target)  # TODO use is_attacking
            and subject.attitude.get(target) >= 0
        ]

        memes.extend(aggressions)

        return [Idea(meme, 1, subject) for meme in memes], len(aggressions) > 0
