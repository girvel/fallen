from ecs import OwnedEntity

from src.entities.special.screen import Colors


class Tree(OwnedEntity):
    character = 'T'  # TODO use this syntax by default?

    def __init__(self):
        super().__init__(name='tree', color = Colors.Green, health=100)