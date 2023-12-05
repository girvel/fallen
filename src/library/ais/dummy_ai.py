from ecs import Entity, exists

from src.engine.acting.action import Action
from src.library.ai_modules.follower import Follower
from src.library.ai_modules.pather import Pather
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.lib.concurrency import wait_while
from src.lib.typed_dict import TypeDict
from src.engine.ai import Perception


class DummyAi(Entity):
    def __init__(self):
        self.composite = TypeDict([
            Pather(),
            Follower(3),
            SpacialMemory(),
        ])

    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        self.composite[SpacialMemory].use(subject, perception)

        if (target := self.composite[Follower].use(subject, perception)) != Follower.no_change_signal:
            self.composite[Pather].going_to = target

        if move := self.composite[Pather].use(subject, perception, self.composite[SpacialMemory]):
            return move

    def clear(self):
        self.composite[Pather].going_to = None
        self.composite[Follower].subject = None

def wait_finish(*dummies, threshold=0):
    yield
    yield from wait_while(lambda: sum(
        int(
            not exists(dummy) or
            dummy.ai.composite[Pather].going_to is not None or
            dummy.ai.composite[Follower].active
        )
        for dummy in dummies
    ) > threshold)
