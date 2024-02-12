import logging
from dataclasses import dataclass, field

from ecs import Entity

from src.engine.ai import Perception
from src.engine.attitude.implementation import Relation
from src.engine.meme import Aggression, Idea, DangerousEntity
from src.lib.query import Q
from src.assets.actions.hand_attack import WeaponAttack
from src.assets.tiles.body import Body


@dataclass
class Observer:
    known_objects: list[Entity] = field(default_factory=list)  # TODO ExpiringCollection
    warning_attitude_threshold: int = Relation.Neutrality

    # TODO OPT different collection for ideas? dict? list with idea kind ID as index?
    # TODO OPT determine the dict/list speed K
    # TODO OPT isinstance vs comparing a variable
    def use(self, subject, perception: Perception) -> tuple[list[Idea], bool]:
        memes = []
        notices_danger = False

        for p, seen_entity in perception.vision["physical"].items():
            if seen_entity is None: continue

            if (
                (target := ~Q(seen_entity).act[WeaponAttack].target) is not None and
                subject.attitude.get(target) >= 0
            ):
                memes.append(Aggression(seen_entity, target))

            if subject.attitude.get(seen_entity) < self.warning_attitude_threshold:
                notices_danger = True
                if seen_entity not in self.known_objects:
                    memes.append(DangerousEntity(p, seen_entity))
                    self.known_objects.append(subject)

        for p, seen_entity in perception.vision["tiles"].items():
            if isinstance(seen_entity, Body) and seen_entity not in self.known_objects:
                memes.append(DangerousEntity(p, seen_entity))
                self.known_objects.append(seen_entity)

        return [Idea(meme, 1, subject) for meme in memes], notices_danger
