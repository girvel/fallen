from ecs import DynamicEntity

from src.engine.acting.damage import Health, Weapon, ArmorKind, DamageKind
from src.engine.assets import reserved_names
from src.engine.name import CompositeName, Name
from src.engine.output.colors import ColorPair, blue
from src.entities.ais.dummy_ai import DummyAi
from src.entities.tiles.body import body_factory
from src.lib.vector import map_grid
from src.systems.ai import Kind, Senses


class Mother(DynamicEntity):
    character = 'm'
    color = ColorPair(blue)
    on_death = body_factory
    layer = "physical"

    def __init__(self):
        self.sex = "female"
        self.name = CompositeName(reserved_names.lilia, reserved_names.kinds_female)

        self.health = Health(50, ArmorKind.Organic)
        self.weapon = Weapon(4, DamageKind.Slashing)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

    def after_load(self, level):
        self.ai.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
