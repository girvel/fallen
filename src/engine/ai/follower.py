import logging

from src.lib.period.period import Period
from src.lib.vector import abs2, sub2


# @enum
# class TargetChange:
#     NoChange: ()
#     Dismiss: ()
#     Change: ()


class Follower:
    subject = None

    def __init__(self, d):
        self.d = d
        self.period = Period(d)

    def try_producing_target(self, subject, perception):
        if self.subject is None: return False
        if abs2(sub2(subject.p, self.subject.p)) <= self.d: return None

        if self.period.step():
            return self.subject.p
        return False
