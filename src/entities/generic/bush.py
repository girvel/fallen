from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Bush(OwnedEntity):
    name = 'bush'
    character = 'b'
    color = Colors.Green
    health = 10
