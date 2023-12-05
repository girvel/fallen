from dataclasses import dataclass, field

from ecs import Entity

from src.engine.attitude.implementation import Constants
from src.engine.meme import Aggression, Idea, DangerousEntity
from src.lib.query import Q
from src.library.actions.hand_attack import HandAttack
from src.library.tiles.body import Body
from src.engine.ai import Perception


@dataclass
class Observer:
    known_objects: list[Entity] = field(default_factory=list)  # TODO ExpiringCollection
    warning_attitude_threshold: int = Constants.Neutrality

    # TODO OPT different collection for ideas? dict? list with idea kind ID as index?
    # TODO OPT determine the dict/list speed K
    # TODO OPT isinstance vs comparing a variable
    def use(self, subject: Entity, perception: Perception) -> tuple[list[Idea], bool]:
        memes = []
        notices_danger = False

        aggressions = [
            Aggression(e, target)
            for e in perception.vision["physical"].values()
            if (target := ~Q(e).act[HandAttack].target)
               and subject.attitude.get(target) >= 0
        ]

        if len(aggressions) > 0:
            notices_danger = True
            memes.extend(aggressions)

        for p, e in perception.vision["tiles"].items():
            if isinstance(e, Body) and e not in self.known_objects:
                memes.append(DangerousEntity(p, e))
                self.known_objects.append(e)

        for p, e in perception.vision["physical"].items():
            if (
                e is not None and
                subject.attitude.get(e) < self.warning_attitude_threshold
            ):
                notices_danger = True
                if e not in self.known_objects:
                    memes.append(DangerousEntity(p, e))
                    self.known_objects.append(subject)

        return [Idea(meme, 1, subject) for meme in memes], notices_danger
