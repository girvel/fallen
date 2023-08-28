import random
from enum import Enum

from src.lib.period.random_period import RandomPeriod
from src.lib.vector import directions, add2
from src.systems.acting.actions.move import Move


class Mode(Enum):
    Wandering = 0
    AtHome = 1


class PeasantAi:
    decision_period = RandomPeriod(2, 4)
    mode_period = RandomPeriod(10, 26)
    mode = Mode(random.randrange(len(Mode)))

    def make_decision(self, subject, perception):
        decision_step = self.decision_period.step()
        if decision_step == 0: return

        free_directions = [d for d in directions if perception.vision.get(add2(subject.p, d)) is None]
        if len(free_directions) == 0: return

        if self.mode_period.step(decision_step):
            self.mode = Mode((self.mode.value + 1) % len(Mode))

        match self.mode:
            case Mode.Wandering:
                return Move(random.choice(free_directions))
