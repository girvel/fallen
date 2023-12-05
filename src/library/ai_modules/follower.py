from typing import Literal

from ecs import Entity

from src.lib.period.period import Period
from src.lib.vector import d2, int2


class Follower:
    subject: Entity | None = None
    no_change_signal = object()

    def __init__(self, d):
        self.d = d
        self.period = Period(d)
        self.active = False

    def use(self, subject, perception) -> int2 | None | object:
        self.active = False

        if not self.period.step(): return self.no_change_signal

        if self.subject is None or self.subject.p not in perception.vision["physical"]: return self.no_change_signal
        if d2(subject.p, self.subject.p) <= self.d: return None

        self.active = True
        return self.subject.p
