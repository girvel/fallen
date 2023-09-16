from abc import abstractmethod, ABC

from ecs import OwnedEntity

from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.entities.special.infosphere import Infosphere


class Action(ABC):
    @abstractmethod
    def execute(self, actor: OwnedEntity, level: Level, infosphere: Infosphere, hades: Hades, genesis: Genesis):
        pass
