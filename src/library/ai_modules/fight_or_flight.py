import random
from dataclasses import dataclass, field
from typing import Any, ClassVar

from ecs import exists

from src.engine.ai import Perception
from src.lib.limited import Limited
from src.lib.vector.vector import d2, int2


# TODO OPT use the stream of ideas with separate meme for enemies
@dataclass
class FightOrFlight:
    prefer_fight: bool
    frequency_restrictor: Limited = field(default_factory=lambda: Limited(5, 0, 0))
    current_target: Any = None

    no_change_signal: ClassVar[object] = object()

    def use(
        self, subject, perception: Perception
    ) -> int2 | None | object:
        self.frequency_restrictor.move(-1)
        if not self.frequency_restrictor.is_min(): return self.no_change_signal

        if self.current_target and self.prefer_fight:
            if exists(self.current_target) and self.current_target.p in perception.vision["physical"]:
                return self.current_target.p

            self.current_target = None

        if len(enemies := [
            e
            for _, grid in perception.vision.items()
            for e in grid.values()
            if e is not None and subject.attitude.get(e) < 0
        ]) == 0:
            return self.no_change_signal

        self.frequency_restrictor.reset_to_max()
        if self.prefer_fight:
            self.current_target = random.choice(enemies)
            return self.current_target.p
        else:
            return max(  # TODO OPT use a ray?
                (p for p, e in perception.vision["physical"].items() if e is None),
                key=lambda p: sum(d2(p, e.p) for e in enemies),
            )
