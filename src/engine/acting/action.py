from abc import abstractmethod, ABC

from ecs import Entity

from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


class Action(ABC):
    succeeded: bool = True

    @abstractmethod
    def execute(self, actor, hades: Hades, genesis: Genesis):
        pass
