import random

from ecs import OwnedEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import Colors


class Flower(OwnedEntity):
    name = 'Flower'
    character = 'F'

    def __init__(self):
        self.health = Health(1, ArmorKind.Organic)
        self.color = random.choice([Colors.Cyan, Colors.Default, Colors.Magenta])
