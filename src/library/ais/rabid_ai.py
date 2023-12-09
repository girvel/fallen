import random

from src.library.actions.hand_attack import HandAttack
from src.library.actions.move import Move
from src.library.ai_modules.pather import Pather
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.lib.composite import Composite
from src.lib.vector.vector import sub2, abs2
from src.engine.ai import Kind, classified_as


class RabidAi:
    def __init__(self):
        self.composite = Composite([
            Pather(),
            SpacialMemory(),
        ])

    def make_decision(self, subject, perception):
        self.composite[SpacialMemory].use(subject, perception)

        if action := self.composite[Pather].use(subject, perception, self.composite[SpacialMemory]): return action

        possible_targets = [
            e for e in perception.vision["physical"].values()
            if e is not None and e is not subject and classified_as(e, Kind.Animate)
        ]
        if len(possible_targets) == 0: return Move(random.choice(self.composite[Pather].free_directions))

        target = random.choice(possible_targets)

        v = sub2(target.p, subject.p)
        if abs2(v) == 1:
            return HandAttack(target)
        else:
            self.composite[Pather].going_to = target.p
