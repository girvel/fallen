import random

from ecs import DynamicEntity, exists
from rust_enum import Option

from src.engine.ai.pather import PathTarget
from src.lib.vector import d2
from src.systems.ai import Perception


class FightOrFlight:
    current_target: Option[DynamicEntity] = Option.Nothing()

    def __init__(self, prefer_fight: bool):
        self.prefer_fight = prefer_fight

    def use(
        self, subject: DynamicEntity, perception: Perception
    ) -> Option[PathTarget]:

        if target := self.current_target.unwrap_or():
            if exists(target) and target.p in perception.vision.physical:
                return Option.Some(PathTarget.Some(target.p))

            self.current_target = Option.Nothing()

        enemies = [e for e in perception.vision.physical.values() if e is not None and subject.attitude.get(e) < 0]
        if len(enemies) == 0: return Option.Nothing()

        if self.prefer_fight:
            self.current_target = Option.Some(random.choice(enemies))
            return self.current_target.map(lambda t: PathTarget.Some(t.p))
        else:
            return Option.Some(PathTarget.Some(max(
                (p for p, e in perception.vision.physical.items() if e is None),
                key=lambda p: sum(d2(p, e.p) for e in enemies),
            )))
