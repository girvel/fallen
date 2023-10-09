from src.engine.acting.damage import Weapon, Health, DamageKind, ArmorKind
from src.engine.assets import reserved_names
from src.engine.name import CompositeName
from src.engine.traits import Traits
from src.entities.abstract.human import Human
from src.systems.ai import Senses


class Player(Human):
    character = '@'

    ai = None  # set to IO on level loading
    act = None
    faction = None

    on_death = lambda *_, **__: None

    def __post_init__(self):
        self.name = CompositeName(reserved_names.hugh, reserved_names.kinds_male)

        self.sex = "male"
        self.weapon = Weapon(1, DamageKind.Crushing)
        self.health = Health(10, ArmorKind.Organic)
        self.senses = Senses(24, 40, 0)
        self.traits = Traits()
