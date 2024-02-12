import random

from src.assets.ai_modules.pather import Pather
from src.assets.ai_modules.spacial_memory import PathMemory, CharacterMemory
from src.lib.period.random_period import RandomPeriod
from src.lib.time import Time
from src.lib.toolkit import chance


class PeasantAi:
    def __init__(self):
        # TODO NEXT extract timetable logic
        self.timetable = (
            (Time(1), self.wander),
            (Time(3), self.sleep),
            (Time(7), self.wander),
        )
        self.current_row_i = -1

        self.lagging_period = RandomPeriod(4, 11)
        self.wandering_pause = RandomPeriod(2, 5)

        self.pather = Pather()
        self.path_memory = PathMemory()
        self.character_memory = CharacterMemory()

    def after_creation(self, subject):
        self.path_memory.knows(subject.level)
        self.character_memory.knows(subject.level)

    def make_decision(self, subject, perception):
        if chance(.3): self.path_memory.use(subject, perception)
        if chance(.1): self.character_memory.use(subject, perception)

        if self.lagging_period.step(): return

        # TODO NEXT extract timetable logic
        next_i = (self.current_row_i + 1) % len(self.timetable)
        if subject.level.time.total_seconds > self.timetable[next_i][0].total_seconds:
            self.current_row_i = next_i

        return self.timetable[self.current_row_i][1](subject, perception)

    def sleep(self, subject, perception):
        return

    def wander(self, subject, perception):
        if (move := self.pather.use(subject, perception, self.path_memory)) is not None: return move
        if not self.wandering_pause.step(): return
        self.pather.going_to = random.choice(list(iter(perception.vision["physical"])))
