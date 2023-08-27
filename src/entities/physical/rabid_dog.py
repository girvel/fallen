import random

from ecs import OwnedEntity

from src.systems.acting.attack import DamageKind, ArmorKind, Health, Weapon
from src.systems.ai import Kind


class RabidDog(OwnedEntity):
    name = 'Rabid dog'
    character = 'd'
    vision = 10

    def __init__(self):
        self.weapon = Weapon(3, DamageKind.Piercing)
        self.health = Health(20, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}

    def choose_target(self, visible_targets):
        filtered_targets = [
            t for t in visible_targets
            if t != self and "classifiers" in t and Kind.Animate in t.classifiers
        ]

        return len(filtered_targets) > 0 and random.choice(filtered_targets) or None
