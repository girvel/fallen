from ecs import OwnedEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.io.colors import Colors

from src.systems.ai import Kind


class Table(OwnedEntity):
    name = 'Table'
    character = '"'
    color = Colors.Yellow
    classifiers = {Kind.Table}

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
