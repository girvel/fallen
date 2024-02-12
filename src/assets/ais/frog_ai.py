import random

from ecs import Entity

from src.assets.actions.jump import Jump
from src.engine.acting.action import Action
from src.engine.ai import Perception
from src.lib.toolkit import chance
from src.lib.vector import vector


class FrogAi(Entity):
    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        return Jump(random.choice(vector.directions), 1 if chance(.3) else 2)
