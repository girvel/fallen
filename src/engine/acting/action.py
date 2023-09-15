from abc import abstractmethod, ABC

from ecs import OwnedEntity

from src.entities.special.level import Level


class Action(ABC):
    @abstractmethod
    def execute(self, actor: OwnedEntity, level: Level, hades: OwnedEntity, genesis: OwnedEntity):
        pass
