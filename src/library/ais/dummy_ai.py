from ecs import Entity, exists

from src.engine.acting.action import Action
from src.engine.ai import Perception
from src.lib.composite import Composite
from src.lib.concurrency import wait_while
from src.library.ai_modules.follower import Follower
from src.library.ai_modules.pather import Pather
from src.library.ai_modules.spacial_memory import PathMemory


class DummyAi(Entity):
    def __init__(self):
        self.composite = Composite([
            Pather(),
            Follower(3),
            PathMemory(),
        ])

    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        self.composite[PathMemory].use(subject, perception)

        if (target := self.composite[Follower].use(subject, perception)) != Follower.no_change_signal:
            self.composite[Pather].going_to = target

        if move := self.composite[Pather].use(subject, perception, self.composite[PathMemory]):
            return move

    def clear(self):
        self.composite[Pather].going_to = None
        self.composite[Follower].subject = None

# TODO shit, rewrite
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
