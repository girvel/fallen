from abc import ABC, abstractmethod

from ecs import DynamicEntity

from src.systems.ai import Perception


class CompositeAi(ABC):
    @abstractmethod
    def _make_decision(self, subject, perception):
        ...

    _current_subject: DynamicEntity | None = None
    _current_perception: Perception | None = None

    def make_decision(self, subject, perception):
        self._current_subject = subject
        self._current_perception = perception
        return self._make_decision(subject, perception)

    def use(self, module: type, *args, **kwargs):
        return self.composite[module].use(self._current_subject, self._current_perception, *args, **kwargs)
