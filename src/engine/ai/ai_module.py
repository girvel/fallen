from abc import ABCMeta, abstractmethod
from typing import TypeVar, Generic, Any

from ecs import DynamicEntity

from src.systems.ai import Perception

T = TypeVar('T')

class AiModule(Generic[T], metaclass=ABCMeta):
    period: Any

    def use(self, subject: DynamicEntity, perception: Perception) -> T | None:
        return self._use(subject, perception) if self.period.step() else None

    @abstractmethod
    def _use(self, subject: DynamicEntity, perception: Perception) -> T | None:
        ...
