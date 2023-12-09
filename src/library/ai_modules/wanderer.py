import random

from ecs import Entity

from src.library.actions.move import Move
from src.lib.vector.vector import int2
from src.engine.ai import Perception


class Wanderer(Entity):
    def use(self, subject, perception: Perception, free_directions: list[int2]) -> Move | None:
        if len(free_directions) > 0:
            return Move(random.choice(free_directions))
        return None
