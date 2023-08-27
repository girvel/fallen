from ecs import OwnedEntity

from src.entities.ais.fire_ai import FireAi
from src.entities.ais.io import Colors
from src.systems.acting.damage import Weapon, DamageKind
from src.systems.ai import Senses


class Fire(OwnedEntity):
    name = 'fire'
    character = '*'
    color = Colors.Red
    weapon = Weapon(5, DamageKind.Fire)
    senses = Senses(0, 0, 0)
    ai = FireAi()
