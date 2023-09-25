import random

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.acting.actions.say import Say
from src.engine.attitude.implementation import Faction
from src.entities.ais.dummy_ai import DummyAi
from src.lib.query import Query
from src.systems.ai import Perception


class BrotherAi(DummyAi):
    bye_lines = [
        "Пока, {}.",
        "Пока, {}.",
        "{}, пока!",
        "Прощай, {}. Буду скучать.",
        "{}, пока-пока.",
        "{}, кстати, мы расстаёмся.",
    ]

    def __init__(self):
        self.said_bye_to = set()
        super().__init__()

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        if (neighbour := next((
            e for e in perception.vision.physical.values()
            if ~Query(e).faction == Faction.Villagers
            and e not in self.said_bye_to
        ), None)):
            self.said_bye_to.add(neighbour)

            line = random.choice(self.bye_lines)
            self.bye_lines.remove(line)
            return Say(line.format(neighbour.name))

        return super().make_decision(subject, perception)
