import random

from ecs import Entity

from src.engine.acting.action import Action
from src.library.actions.jump import Jump
from src.library.ai_modules.wanderer import Wanderer
from src.lib import vector
from src.lib.toolkit import chance
from src.engine.ai import Perception


class FrogAi(Entity):
    def __init__(self):
        self.wanderer = Wanderer()

    def make_decision(self, subject: Entity, perception: Perception) -> Action:
        return Jump(random.choice(vector.directions), 1 if chance(.3) else 2)
