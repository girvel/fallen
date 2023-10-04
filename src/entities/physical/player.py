from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.traits import Traits
from src.entities.abstract.human import Human
from src.systems.ai import Kind, Senses


class Player(Human):
    character = '@'

    ai = None  # set to IO on level loading
    act = None
    faction = None

    on_death = lambda *_, **__: None

    def __init__(self):
        self.name = "Майк"
        self.weapon = Weapon(1, DamageKind.Crushing)
        self.health = Health(10, ArmorKind.Organic)
        self.senses = Senses(24, 40, 0)
        self.traits = Traits()
