from ecs import DynamicEntity

from typing import Protocol

from src.lib.vector import int2
from src.library.special.level import Level


class EntityFactory(Protocol):
    def __call__(self, *, p: int2, level: Level) -> DynamicEntity:
        ...
