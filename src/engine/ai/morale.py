import logging
from dataclasses import dataclass

from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.engine.acting.actions.attack import Attack
from src.lib.query import Query
from src.systems.ai import Perception


@dataclass
class Morale:
    aggression_cost: float = 35

    def update(self, subject: OwnedEntity, perception: Perception) -> Action:
        aggressives = [
            e for e in perception.vision.physical.values()
            if isinstance(~Query(e).act, Attack) and subject.attitude.get(e.act.target) > 0
        ]

        for e in aggressives:
            subject.attitude.move(e, -self.aggression_cost)
            logging.info(f"{subject.name} does not like what {e.name} is doing (-{self.aggression_cost})")
