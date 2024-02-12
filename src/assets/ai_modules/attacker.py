import random

from ecs import Entity, exists

from src.assets.actions.hand_attack import WeaponAttack
from src.lib.vector.vector import directions, add2, d2
from src.engine.ai import Perception


class Attacker:
    def try_attacking(
        self, subject, perception: Perception, current_target: Entity | None = None
    ) -> WeaponAttack | None:

        if current_target and exists(current_target):
            return (d2(subject.p, current_target.p) <= 1
                    and WeaponAttack(current_target)
                    or None)

        enemies = [
            e for d in directions
            if (e := perception.vision["physical"].get(add2(subject.p, d))) is not None
            and subject.attitude.get(e) < 0
        ]

        return len(enemies) > 0 and WeaponAttack(random.choice(enemies)) or None
