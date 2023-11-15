import random

from ecs import DynamicEntity, exists

from src.lib.vector import d2, int2
from src.systems.ai import Perception


class FightOrFlight:
    current_target: DynamicEntity | None = None
    no_change_signal = object()

    def __init__(self, prefer_fight: bool):
        self.prefer_fight = prefer_fight

    def use(
        self, subject: DynamicEntity, perception: Perception
    ) -> int2 | None | object:

        if self.current_target:
            if exists(self.current_target) and self.current_target.p in perception.vision.physical:
                return self.current_target.p

            self.current_target = None

        if len(enemies := [
            e
            for _, grid in perception.vision
            for e in grid.values()
            if e is not None and subject.attitude.get(e) < 0
        ]) == 0:
            return self.no_change_signal

        if self.prefer_fight:
            self.current_target = random.choice(enemies)
            return self.current_target.p
        else:
            return max(
                (p for p, e in perception.vision.physical.items() if e is None),
                key=lambda p: sum(d2(p, e.p) for e in enemies),
            )
