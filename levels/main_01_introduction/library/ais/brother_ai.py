import random

from ecs import Entity

from src.engine.acting.action import Action
from src.library.actions.say import Say
from src.engine.attitude.implementation import Faction
from src.library.ais.dummy_ai import DummyAi
from src.lib.query import Q
from src.engine.ai import Perception


class BrotherAi(DummyAi):
    bye_lines = [
        "Пока, {}.",
        "Пока, {}.",
        "{}, пока!",
        "Прощай, {}. Буду скучать.",
        "{}, пока-пока.",
        "{}, кстати, мы расстаёмся.",
    ]

    cutscene_aware_flag = None

    def __init__(self):
        self.said_bye_to = set()
        self.speech_enabled = False
        super().__init__()

    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        if (
            len(self.bye_lines) > 0 and
            (neighbour := next((
                e for e in perception.vision["physical"].values()
                if ~Q(e).faction == Faction.Villagers
                and e not in self.said_bye_to
            ), None))
        ):
            self.said_bye_to.add(neighbour)

            line = random.choice(self.bye_lines)
            self.bye_lines.remove(line)
            return Say(line.format(~Q(neighbour.name).first or neighbour.name))

        return super().make_decision(subject, perception)
