import logging
from abc import ABC, abstractmethod

from ecs import DynamicEntity, exists

from src.lib.query import Q


class Aggressive(ABC):
    @abstractmethod
    def get_victims(self, actor: DynamicEntity) -> list[DynamicEntity]:
        ...


def is_attacking(source: DynamicEntity, target: DynamicEntity) -> bool:
    return (aggression := ~Q(source).act[Aggressive]) is not None and target in aggression.get_victims()
