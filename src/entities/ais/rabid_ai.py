import random

from src.engine.acting.actions.attack import Attack
from src.engine.acting.actions.move import Move
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.pather import Pather
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.typed_dict import TypeDict
from src.lib.vector import sub2, abs2


from src.systems.ai import classified_as, Kind


class RabidAi:
    def __init__(self):
        self.composite = TypeDict([
            FightOrFlight(False),
            Pather(),
            SpacialMemory(),
        ])

    def make_decision(self, subject, perception):
        self.composite[SpacialMemory].use(subject, perception)

        if (target := self.composite[FightOrFlight].use(subject, perception)) != FightOrFlight.no_change_signal:
            self.composite[Pather].going_to = target

        if action := self.composite[Pather].use(subject, perception, self.composite[SpacialMemory]): return action

        possible_targets = [
            e for e in perception.vision.physical.values()
            if e is not None and e is not subject and classified_as(e, Kind.Animate)
        ]
        if len(possible_targets) == 0: return Move(random.choice(self.composite[Pather].free_directions))

        target = random.choice(possible_targets)

        v = sub2(target.p, subject.p)
        if abs2(v) == 1:
            return Attack(target)
        else:
            self.composite[Pather].going_to = target.p
