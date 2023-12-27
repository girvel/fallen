from ecs import Entity
from src.engine.acting.action import Action
from src.engine.ai import Perception


class StaticAi(Entity):
    def __init__(self, action_factory):
        self.action_factory = action_factory

    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        return self.action_factory(subject, perception)
