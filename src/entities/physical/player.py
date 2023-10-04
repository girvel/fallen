from ecs import DynamicEntity

from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.traits import Traits
from src.systems.ai import Kind, Senses


class Player(DynamicEntity):
    character = '@'

    ai = None  # set to IO on level loading
    act = None
    faction = None
    layer = "physical"

    on_death = lambda *_, **__: None

    traits = Traits()

    def __init__(self):
        self.name = "Майк"
        self.weapon = Weapon(1, DamageKind.Crushing)
        self.health = Health(10, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
        self.senses = Senses(24, 40, 0)
