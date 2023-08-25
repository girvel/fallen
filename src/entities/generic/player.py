from ecs import OwnedEntity

from src.systems.acting.attack import DamageKind, ArmorKind, Weapon, Health
from src.systems.ai import Kind, Senses


class Player(OwnedEntity):
    name = 'Sir Aethan'
    character = '@'
    solid_flag = None

    inspects = None

    senses = Senses(25, 40, 1)

    def __init__(self):
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.health = Health(100, ArmorKind.Steel)
        self.classifiers = {Kind.Animate}
