import logging
from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.actions.attack import Attack
from src.lib.query import Query
from src.systems.ai import Perception


@dataclass
class Morale:
    aggression_cost: float = 35

    def update(self, subject: DynamicEntity, perception: Perception):
        attitude_changes = [
            (e, -self.aggression_cost) for e in perception.vision.physical.values()
            if isinstance(~Query(e).act, Attack) and subject.attitude.get(e.act.target) >= 0
        ]

        for e, offset in attitude_changes:
            subject.attitude.move(e, offset)
            logging.info(f"{subject.name} does not like what {e.name} is doing ({offset} -> {subject.attitude.get(e)})")

        return attitude_changes
