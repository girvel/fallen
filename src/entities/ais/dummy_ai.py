from ecs import DynamicEntity
from src.engine.acting.action import Action
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather
from src.systems.ai import Perception


class DummyAi(DynamicEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(2)

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        if target := self.follower.try_producing_target(subject, perception).unwrap_or(): self.pather.going_to = target
        if move := self.pather.try_going(subject, perception).unwrap_or(): return move
