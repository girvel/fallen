import random

from ecs import DynamicEntity
from rust_enum import Option

from src.engine.acting.action import Action
from src.engine.acting.actions.move import Move
from src.lib.vector import int2
from src.systems.ai import Perception


class Wanderer(DynamicEntity):
    def use(self, subject: DynamicEntity, perception: Perception, free_directions: list[int2]) -> Option[Action]:
        if len(free_directions) > 0:
            return Option.Some(Move(random.choice(free_directions)))
        return Option.Nothing()
