from typing import Optional

from src.lib.period.period import Period
from src.lib.rust_enum import enum
from src.lib.vector import abs2, sub2, int2


@enum
class TargetChange:
    Nothing = {}
    To = {"target": Optional[int2]}


class Follower:
    subject = None

    def __init__(self, d):
        self.d = d
        self.period = Period(d)

    def try_producing_target(self, subject, perception):
        if self.subject is None or self.subject.p not in perception.vision.physical: return TargetChange.Nothing()
        if abs2(sub2(subject.p, self.subject.p)) <= self.d: return TargetChange.To(None)

        if self.period.step():
            return TargetChange.To(self.subject.p)
        return TargetChange.Nothing()
