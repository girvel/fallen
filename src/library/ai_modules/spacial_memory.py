from src.library.special.level import Level
from src.lib.vector.grid import grid_map, grid_set
from src.engine.ai import Perception


class SpacialMemory(dict):
    def __missing__(self, key: Level):
        self[key] = grid_map(key.grids["physical"], lambda _: None)
        return self[key]

    def use(self, subject, perception: Perception):
        for p, entity in perception.vision["physical"].items():
            grid_set(self[subject.level], p, entity is not None and entity.character or Level.no_entity_character)

    def knows(self, level: Level):
        self[level] = grid_map(
            level.grids["physical"],
            lambda e: e is None and Level.no_entity_character or e.character
        )
