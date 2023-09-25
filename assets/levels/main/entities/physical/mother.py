from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.output.colors import Colors
from src.entities.ais.dummy_ai import DummyAi
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid
from src.systems.ai import Kind, Senses


class Mother(DynamicEntity):
    character = 'm'
    color = Colors.Blue
    on_death = body_factory
    spacial_memory = None

    def __init__(self):
        self.sex = "female"
        self.name = "Миссис Кайндс"
        self.health = Health(50, ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

    def after_load(self, level):
        self.spacial_memory = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
