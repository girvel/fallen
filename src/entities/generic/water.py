from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Water(OwnedEntity):
    character = '~'

    def __init__(self):
        super().__init__(name='water', color=Colors.WhiteOnBlue)