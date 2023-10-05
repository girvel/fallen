from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.concurrency import wait_while
from src.systems.ai import Perception


class DummyAi(DynamicEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(2)
        self.spacial_memory = SpacialMemory()
        self.is_busy = False

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        self.is_busy = True

        self.spacial_memory.push(subject, perception)
        if target := self.follower.try_producing_target(subject, perception).unwrap_or(): self.pather.going_to = target
        if move := self.pather.try_going(subject, perception, self.spacial_memory).unwrap_or(): return move

        self.is_busy = False

def wait_finish(dummy):
    yield
    yield from wait_while(lambda: dummy.ai.is_busy)
