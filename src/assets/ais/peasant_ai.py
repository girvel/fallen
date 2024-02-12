import random

from src.assets.actions.move import Move
from src.lib.time import Time
from src.lib.vector import vector


class PeasantAi:
    def __init__(self):
        self.timetable = (
            (Time(21), self.sleep),
            (Time(1), self.wander),
        )
        self.current_row_i = 0

    def make_decision(self, subject, perception):
        next_i = (self.current_row_i + 1) % len(self.timetable)
        if subject.level.time.total_seconds > self.timetable[next_i][0].total_seconds:
            self.current_row_i = next_i

        return self.timetable[self.current_row_i][1](subject, perception)

    def sleep(self, subject, perception):
        return

    def wander(self, subject, perception):
        return Move(random.choice(vector.directions))
