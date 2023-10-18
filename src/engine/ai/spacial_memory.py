from ecs import DynamicEntity

from src.entities.special.level import Level
from src.lib.vector import map_grid, grid_set
from src.systems.ai import Perception


class SpacialMemory(dict):
    def __missing__(self, key: Level):
        self[key] = map_grid(key.grids.physical, lambda _: None)
        return self[key]

    def use(self, subject: DynamicEntity, perception: Perception):
        for p, entity in perception.vision.physical.items():
            grid_set(self[subject.level], p, entity is not None and entity.character or ".")
