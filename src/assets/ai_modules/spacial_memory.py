from abc import ABCMeta, abstractmethod

from src.assets.special.level import Level
from src.lib.vector.grid import grid_map, grid_set
from src.engine.ai import Perception

# TODO do GeneralSpacialMemory


class AbstractSpacialMemory(dict, metaclass=ABCMeta):
    def use(self, subject, perception: Perception):
        for p, entity in perception.vision["physical"].items():
            grid_set(self[subject.level], p, self._map_entity(entity))

    def knows(self, level: Level):
        self[level] = grid_map(level.grids["physical"], self._map_entity)

    @abstractmethod
    def _map_entity(self, entity):
        ...


class PathMemory(AbstractSpacialMemory):
    def __missing__(self, key: Level):
        self[key] = grid_map(key.grids["physical"], lambda _: 1)
        return self[key]

    def _map_entity(self, entity):
        return int(entity is None)


class CharacterMemory(AbstractSpacialMemory):
    def __missing__(self, key: Level):
        self[key] = grid_map(key.grids["physical"], lambda _: None)
        return self[key]

    def _map_entity(self, entity):
        return entity is not None and entity.character or Level.no_entity_character
