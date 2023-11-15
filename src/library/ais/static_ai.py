from ecs import DynamicEntity
from src.engine.acting.action import Action
from src.systems.ai import Perception


class StaticAi(DynamicEntity):
    def __init__(self, action_factory):
        self.action_factory = action_factory

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        return self.action_factory(subject, perception)
