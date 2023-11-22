from dataclasses import dataclass, field

from ecs import DynamicEntity

from src.engine.meme import Aggression, Idea, DangerousEntity
from src.lib.query import Q
from src.library.actions.hand_attack import HandAttack
from src.library.tiles.body import Body
from src.systems.ai import Perception


@dataclass
class Observer:
    known_objects: list[DynamicEntity] = field(default_factory=list)  # TODO ExpiringCollection
    warning_attitude_threshold: int = -100

    def use(self, subject: DynamicEntity, perception: Perception) -> tuple[list[Idea], bool]:
        memes = []

        aggressions = [
            Aggression(e, target)
            for e in perception.vision.physical.values()
            if (target := ~Q(e).act[HandAttack].target)
               and subject.attitude.get(target) >= 0
        ]

        memes.extend(aggressions)

        for p, e in perception.vision.tiles.items():
            if isinstance(e, Body) and e not in self.known_objects:
                memes.append(DangerousEntity(p, e))
                self.known_objects.append(e)

        for p, e in perception.vision.physical.items():
            if (
                e is not None and
                subject.attitude.get(e) < self.warning_attitude_threshold and
                e not in self.known_objects
            ):
                memes.append(DangerousEntity(p, e))
                self.known_objects.append(subject)

        return [Idea(meme, 1, subject) for meme in memes], len(aggressions) > 0
