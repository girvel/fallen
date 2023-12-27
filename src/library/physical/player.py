from src.components import Genesis, Hades
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.acting.damage import Weapon, Health
from src.engine.ai import Senses
from src.engine.attitude.implementation import Faction
from src.engine.inventory import Inventory
from src.engine.language.library import reserved_names
from src.engine.language.name import CompositeName
from src.engine.output.colors import ColorPair, white
from src.engine.traits import Traits
from src.library.abstract.humanoid import Humanoid
from src.library.ais.io import IO
from src.library.special.level import Level


class Player(Humanoid):
    character = '@'
    color = ColorPair(white)

    ai: IO | None
    act = None
    faction = Faction.Villagers

    tick_counter = 0

    afterlife_level: "Level | None" = None

    def __post_init__(self):
        self.name = CompositeName(reserved_names["hugh"], reserved_names["kinds"]["male"])

        self.sex = "male"
        self.weapon = Weapon(1, damage_kind.crushing)
        self.health = Health(10, armor_kind.none)
        self.senses = Senses(24, 30, 0, attention_k=1)
        self.traits = Traits()
        self.inventory = Inventory()

    def on_destruction(self, _hades: Hades, _genesis: Genesis):
        assert self.afterlife_level is not None
        Level.move(self, (5, 3), level=self.afterlife_level)
        return True
