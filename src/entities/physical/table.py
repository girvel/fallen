from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.output.colors import Colors

from src.systems.ai import Kind


class Table(DynamicEntity):
    name = 'Table'
    character = '"'
    color = Colors.Yellow
    classifiers = {Kind.Table}

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
