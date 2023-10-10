from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather, PathTarget
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.concurrency import wait_while
from src.systems.ai import Perception


class DummyAi(DynamicEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(3)
        self.spacial_memory = SpacialMemory()

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        self.spacial_memory.push(subject, perception)
        if target := self.follower.try_producing_target(subject, perception).unwrap_or(): self.pather.going_to = target
        if move := self.pather.try_going(subject, perception, self.spacial_memory).unwrap_or(): return move

    def clear(self):
        self.pather.going_to = PathTarget.Nothing()
        self.follower.subject = None

def wait_finish(*dummies, threshold=0):
    yield
    yield from wait_while(lambda: sum(
        int(dummy.ai.pather.going_to.some() or dummy.ai.follower.active)
        for dummy in dummies
    ) > threshold)
