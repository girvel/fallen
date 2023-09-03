from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors
from src.systems.acting.damage import Health, ArmorKind
from src.systems.ai import Kind


class Table(OwnedEntity):
    name = 'Table'
    character = '"'
    color = Colors.Yellow
    classifiers = {Kind.Table}

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
