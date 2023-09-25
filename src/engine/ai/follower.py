from rust_enum import Option

from src.engine.ai.pather import PathTarget
from src.lib.period.period import Period
from src.lib.vector import d2


class Follower:
    subject = None

    def __init__(self, d):
        self.d = d
        self.period = Period(d)

    def try_producing_target(self, subject, perception) -> Option[PathTarget]:
        if not self.period.step(): return Option.Nothing()

        if self.subject is None or self.subject.p not in perception.vision.physical: return Option.Nothing()
        if d2(subject.p, self.subject.p) <= self.d: return Option.Some(PathTarget.Nothing())

        return Option.Some(PathTarget.Some(self.subject.p))
