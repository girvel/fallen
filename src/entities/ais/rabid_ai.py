import random

from src.engine.acting.actions.attack import Attack
from src.engine.acting.actions.move import Move
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.pather import Pather, PathTarget
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.vector import sub2, abs2


from src.systems.ai import classified_as, Kind


class RabidAi:
    def __init__(self):
        self.fight_or_flight = FightOrFlight(False)
        self.pather = Pather()
        self.spacial_memory = SpacialMemory()

    def make_decision(self, subject, perception):
        self.spacial_memory.use(subject, perception)

        if (target := self.fight_or_flight.use(subject, perception).unwrap_or()) is not None:
            self.pather.going_to = target

        if action := self.pather.use(subject, perception, self.spacial_memory).unwrap_or(): return action

        possible_targets = [
            e for e in perception.vision.physical.values()
            if e is not None and e is not subject and classified_as(e, Kind.Animate)
        ]
        if len(possible_targets) == 0: return Move(random.choice(self.pather.free_directions))

        target = random.choice(possible_targets)

        v = sub2(target.p, subject.p)
        if abs2(v) == 1:
            return Attack(target)
        else:
            self.pather.going_to = PathTarget.Some(target.p)
