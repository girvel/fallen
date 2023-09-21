from dataclasses import dataclass

from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.lib.query import Query
from src.systems.ai import Perception


@dataclass
class Morale:
    aggression_cost: float = 35

    def update(self, subject: OwnedEntity, perception: Perception) -> Action:
        aggressives = [
            e for e in perception.vision.physical.values()
            if ~Query(e).act.target.faction == subject.faction
        ]

        for e in aggressives:
            subject.attitude.move(e, -self.aggression_cost)
