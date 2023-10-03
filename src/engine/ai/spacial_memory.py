from src.entities.special.level import Level
from src.lib.vector import map_grid


class SpacialMemory(dict):
    def __missing__(self, key: Level):
        self[key] = map_grid(key.grids.physical, lambda _: None)
        return self[key]
