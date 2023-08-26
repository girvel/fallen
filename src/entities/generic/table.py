from ecs import OwnedEntity

from src.entities.special.io import Colors
from src.systems.acting.attack import Health, ArmorKind


class Table(OwnedEntity):
    name = 'Table'
    character = '"'
    color = Colors.Yellow

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
