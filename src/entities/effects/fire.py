from ecs import OwnedEntity

from src.entities.ais.fire_ai import FireAi
from src.entities.ais.io import Colors
from src.lib.toolkit import death_chance_from_half_life
from src.systems.acting.damage import Weapon, DamageKind
from src.systems.ai import Senses


class Fire(OwnedEntity):
    name = 'fire'
    character = '*'
    color = Colors.Red

    def __init__(self, half_life=float('inf')):
        self.weapon = Weapon(5, DamageKind.Fire)
        self.senses = Senses(0, 0, 0)
        self.ai = FireAi()
        self.death_chance = death_chance_from_half_life(half_life)
