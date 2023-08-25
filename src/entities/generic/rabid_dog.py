import random

from ecs import OwnedEntity

from src.systems.ai import Kind


class RabidDog(OwnedEntity):
    name = 'rabid_dog'
    character = 'd'
    classifiers = {Kind.Animate}
    health = 20
    power = 5
    vision = 10

    def choose_target(self, visible_targets):
        filtered_targets = [
            t for t in visible_targets
            if t != self and "classifiers" in t and Kind.Animate in t.classifiers
        ]

        return len(filtered_targets) > 0 and random.choice(filtered_targets) or None
