from src.engine.acting.damage import Weapon, Health
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.inventory import Inventory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, white
from src.engine.traits import Traits
from src.library.abstract.humanoid import Humanoid
from src.engine.ai import Senses


class Player(Humanoid):
    character = '@'
    color = ColorPair(white)

    act = None
    faction = None

    tick_counter = 0

    def __post_init__(self):
        self.name = CompositeName(reserved_names["hugh"], reserved_names["kinds"]["male"])

        self.sex = "male"
        self.weapon = Weapon(1, damage_kind.crushing)
        self.health = Health(10, armor_kind.none)
        self.senses = Senses(24, 40, 0)
        self.traits = Traits()
        self.inventory = Inventory()

        self.on_death = lambda *_, **__: True
