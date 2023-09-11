import random

from ecs import OwnedEntity, exists
from rust_enum import Option

from src.engine.reputation import demeanor_towards
from src.lib.vector import int2
from src.systems.ai import Perception


class FightOrFlight:
    current_target: Option[OwnedEntity] = Option.Nothing()

    def __init__(self, prefer_fight: bool):
        self.prefer_fight = prefer_fight

    def try_producing_target(
        self, subject: OwnedEntity, perception: Perception
    ) -> Option[int2]:

        if target := self.current_target.unwrap_or():
            if exists(target) and target.p in perception.vision.physical: return Option.Some(target.p)

            self.current_target = Option.Nothing()

        enemies = [e for e in perception.vision.physical.values() if e is not None and demeanor_towards(subject, e) < 0]
        if len(enemies) == 0: return Option.Nothing()

        if self.prefer_fight:
            self.current_target = Option.Some(random.choice(enemies))
            return self.current_target.map(lambda t: t.p)
        else:
            assert False
