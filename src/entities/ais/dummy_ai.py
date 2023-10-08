from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.concurrency import wait_while
from src.systems.ai import Perception


class DummyAi(CompositeAi):
    def __post_init__(self):
        self.components = [
            Pather(),
            Follower(3),
            SpacialMemory(),
        ]
        
        self.is_busy = False

    def _make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        self.is_busy = True

        self.use(SpacialMemory)
        if target := self.use(Follower): self.pather.going_to = target
        if move := self.use(Pather): return move

        self.is_busy = False

def wait_finish(*dummies, threshold=0):
    yield
    yield from wait_while(lambda: sum(int(dummy.ai.is_busy) for dummy in dummies) > threshold)
