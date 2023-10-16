from src.engine.acting.damage import Weapon, DamageKind, ArmorKind, Health
from src.engine.attitude.implementation import Faction
from src.engine.name import Name
from src.engine.output.colors import ColorPair, cyan
from src.entities.abstract.human import Human
from src.entities.ais.dummy_ai import DummyAi
from src.lib.vector import map_grid
from src.systems.ai import Senses


class Kaledeii(Human):
    name = Name("каледей")
    sex = "male"
    character = 'K'
    color = ColorPair(cyan)

    faction = Faction.Church

    def __init__(self):
        self.health = Health(80, ArmorKind.Steel)
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.senses = Senses(24, 40, 0)
        self.ai = DummyAi()

    def after_load(self, level):
        self.ai.spacial_memory[level] = map_grid(level.grids.physical, lambda e: e is None and "." or e.character)
