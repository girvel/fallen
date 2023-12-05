import logging
from abc import ABC, abstractmethod

from ecs import Entity, exists

from src.lib.query import Q


class Aggressive(ABC):
    @abstractmethod
    def get_victims(self, actor: Entity) -> list[Entity]:
        ...


def is_attacking(source: Entity, target: Entity) -> bool:
    return (aggression := ~Q(source).act[Aggressive]) is not None and target in aggression.get_victims()
