from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.engine.ai.pather import Pather
from src.systems.ai import Perception


class DummyAi(OwnedEntity):
    def __init__(self):
        self.pather = Pather()

    def make_decision(self, subject: OwnedEntity, perception: Perception) -> Action:
        if move := self.pather.try_going(subject, perception).unwrap_or(): return move
