from abc import abstractmethod, ABCMeta

from ecs import Entity

from src.lib.vector.vector import int2
from src.assets.special.level import Level


# TODO try dataclass
class Material(Entity, metaclass=ABCMeta):
    @property
    @abstractmethod
    def layer(self):
        ...

    def __init__(self, *, p: int2, level: Level, **kwargs):
        self.p = p
        self.level = level

        self.__post_init__(**kwargs)

    def __post_init__(self):
        pass
