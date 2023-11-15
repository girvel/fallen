import random

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.library.actions.jump import Jump
from src.library.ai_modules.wanderer import Wanderer
from src.lib import vector
from src.lib.toolkit import chance
from src.systems.ai import Perception


class FrogAi(DynamicEntity):
    def __init__(self):
        self.wanderer = Wanderer()

    def make_decision(self, subject: DynamicEntity, perception: Perception) -> Action:
        return Jump(random.choice(vector.directions), 1 if chance(.3) else 2)
