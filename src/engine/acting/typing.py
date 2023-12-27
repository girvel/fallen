from ecs import Entity

from typing import Protocol

from src.lib.vector.vector import int2
from src.assets.special.level import Level


class EntityFactory(Protocol):
    def __call__(self, *, p: int2, level: Level) -> Entity:
        ...
