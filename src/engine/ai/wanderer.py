import random

from ecs import DynamicEntity

from src.engine.acting.actions.move import Move
from src.lib.vector import int2
from src.systems.ai import Perception


class Wanderer(DynamicEntity):
    def use(self, subject: DynamicEntity, perception: Perception, free_directions: list[int2]) -> Move | None:
        if len(free_directions) > 0:
            return Move(random.choice(free_directions))
        return None
