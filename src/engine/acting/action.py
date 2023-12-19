from abc import abstractmethod, ABC

from ecs import Entity

from src.components import Genesis, Hades


class Action(ABC):
    succeeded: bool = True

    @abstractmethod
    def execute(self, actor, hades: Hades, genesis: Genesis):
        pass
