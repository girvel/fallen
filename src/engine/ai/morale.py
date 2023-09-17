from dataclasses import dataclass

from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.systems.ai import Perception


@dataclass
class Morale:
    aggression_cost: float = 35

    def update(self, subject: OwnedEntity, perception: Perception) -> Action:
        aggressives = [
            e for e in perception.vision.physical.values()
            if hasattr(e, "act")
            and hasattr(e.act, "target")
            and hasattr(e.act.target, "faction")
            and e.act.target.faction == subject.faction

            # TODO query syntax:
            # (~Query(e).act.target.faction).unwrap_or() == (~Query(subject).faction).unwrap_or()
        ]

        for e in aggressives:
            subject.attitude.move(e, -self.aggression_cost)