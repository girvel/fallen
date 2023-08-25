from ecs import OwnedEntity

from src.systems.ai import Kind


class Player(OwnedEntity):
    name = 'player_character'
    character = '@'
    classifiers = {Kind.Animate}
    health = 100
    power = 15
