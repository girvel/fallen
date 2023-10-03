from abc import abstractmethod, ABC

from ecs import DynamicEntity

from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades


class Action(ABC):
    @abstractmethod
    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        pass
