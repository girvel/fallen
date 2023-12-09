import logging
from abc import ABC, abstractmethod

from ecs import Entity, exists

from src.lib.query import Q


class Aggressive(ABC):
    @abstractmethod
    def get_victims(self, actor) -> list:
        ...


def is_attacking(source, target: Entity) -> bool:
    return (aggression := ~Q(source).act[Aggressive]) is not None and target in aggression.get_victims()
