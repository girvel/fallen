from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather, PathTarget
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.concurrency import wait_while
from src.lib.typed_dict import TypeDict
from src.systems.ai import Perception


class DummyAi(DynamicEntity):
    def __init__(self):
        self.composite = TypeDict([
            Pather(),
            Follower(3),
            SpacialMemory(),
        ])

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        self.composite[SpacialMemory].use(subject, perception)

        if target := self.composite[Follower].use(subject, perception).unwrap_or():
            self.composite[Pather].going_to = target

        if move := self.composite[Pather].use(subject, perception, self.composite[SpacialMemory]).unwrap_or():
            return move

    def clear(self):
        self.composite[Pather].going_to = PathTarget.Nothing()
        self.composite[Follower].subject = None

def wait_finish(*dummies, threshold=0):
    yield
    yield from wait_while(lambda: sum(
        int(dummy.ai.composite[Pather].going_to.some() or dummy.ai.composite[Follower].active)
        for dummy in dummies
    ) > threshold)
