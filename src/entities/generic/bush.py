from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Bush(OwnedEntity):
    character = 'b'

    def __init__(self):
        super().__init__(name='bush', color=Colors.Green, health=10)
