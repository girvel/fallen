import logging
from dataclasses import dataclass
from typing import Optional

from src.lib.period.period import Period
from src.lib.vector import abs2, sub2, int2


# @enum
# class TargetChange:
#     Nothing: {}
#     To: {"target": int2}

class TargetChange: pass

@dataclass
class Nothing(TargetChange): pass

@dataclass
class To(TargetChange):
    target: Optional[int2]

TargetChange.Nothing = Nothing
TargetChange.To = To
del Nothing, To


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
