from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.meme import Idea
from src.systems.ai import Perception


@dataclass
class Listener:
    trust_k: float = .9
    idea_weight_threshold: float = .5

    def use(self, subject: DynamicEntity, perception: Perception) -> list[Idea]:
        return [
            Idea(sound.idea.meme, sound.idea.weight * self.trust_k, sound.parent)
            for sound in perception.hearing.values()
            if sound is not None
            and sound.idea is not None
            and sound.idea.weight >= self.idea_weight_threshold
        ]
