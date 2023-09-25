import random

from ecs import DynamicEntity, exists
from rust_enum import Option

from src.engine.acting.actions.attack import Attack
from src.lib.vector import directions, add2, d2
from src.systems.ai import Perception


class Attacker:
    def try_attacking(
        self, subject: DynamicEntity, perception: Perception, current_target: Option[DynamicEntity] = Option.Nothing()
    ) -> Option[Attack]:

        if (target := current_target.unwrap_or()) and exists(target):
            return (d2(subject.p, target.p) <= 1
                and Option.Some(Attack(target))
                or Option.Nothing())

        enemies = [
            e for d in directions
            if (e := perception.vision.physical.get(add2(subject.p, d))) is not None
            and subject.attitude.get(e) < 0
        ]
        return len(enemies) > 0 and Option.Some(Attack(random.choice(enemies))) or Option.Nothing()
