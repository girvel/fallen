from dataclasses import dataclass

from ecs import Entity

from src.engine.meme import Idea, Aggression
from src.lib.toolkit import random_round
from src.engine.ai import Perception


@dataclass
class Morale:
    aggression_base_cost: float = -35
    aggression_to_neutral_base_cost: float = 1
    neutrality_threshold: int = 10

    def use(self, subject: Entity, perception: Perception, ideas: list[Idea]) -> None:
        for idea in ideas:
            match idea.meme:
                case Aggression(source, target):
                    attitude_to_target = subject.attitude.get(target)

                    if attitude_to_target < 0:
                        continue
                    elif attitude_to_target < self.neutrality_threshold:
                        base_cost = self.aggression_to_neutral_base_cost
                    else:
                        base_cost = self.aggression_base_cost

                    subject.attitude.move(source, random_round(base_cost * idea.weight))
