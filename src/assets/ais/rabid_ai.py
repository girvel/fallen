import random

from src.lib.composite import Composite
from src.lib.vector.vector import sub2, abs2
from src.assets.actions.hand_attack import HandAttack
from src.assets.actions.move import Move
from src.assets.ai_modules.pather import Pather
from src.assets.ai_modules.spacial_memory import PathMemory


class RabidAi:
    def __init__(self):
        self.composite = Composite([
            Pather(),
            PathMemory(),
        ])

    def make_decision(self, subject, perception):
        self.composite[PathMemory].use(subject, perception)

        if action := self.composite[Pather].use(subject, perception, self.composite[PathMemory]): return action

        possible_targets = [
            e for e in perception.vision["physical"].values()
            if e is not None and e is not subject and hasattr(e, "animate_flag")
        ]
        if len(possible_targets) == 0: return Move(random.choice(self.composite[Pather].free_directions))

        target = random.choice(possible_targets)

        v = sub2(target.p, subject.p)
        if abs2(v) == 1:
            return HandAttack(target)
        else:
            self.composite[Pather].going_to = target.p
