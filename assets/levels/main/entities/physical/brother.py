from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from assets.levels.main.entities.ais.brother_ai import BrotherAi
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.output.colors import Colors
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid
from src.systems.ai import Kind, Senses


class Brother(DynamicEntity):
    character = 'B'
    color = Colors.Blue
    on_death = body_factory

    def __init__(self):
        self.sex = "male"
        self.name = "Брат"
        self.health = Health(30, ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(12, 0, 0)
        self.ai = BrotherAi()
        self.spacial_memory = SpacialMemory()

    def after_load(self, level):
        self.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
