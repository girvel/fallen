from typing import Optional

from rust_enum import Option

from src.lib.period.period import Period
from src.lib.vector import abs2, sub2, int2


class Follower:
    subject = None

    def __init__(self, d):
        self.d = d
        self.period = Period(d)

    def try_producing_target(self, subject, perception) -> Option[Optional[int2]]:
        if self.subject is None or self.subject.p not in perception.vision.physical: return Option.Nothing()
        if abs2(sub2(subject.p, self.subject.p)) <= self.d: return Option.Some(None)

        if self.period.step():
            return Option.Some(self.subject.p)
        return Option.Nothing()
