import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import Colors


class Flower(DynamicEntity):
    name = 'Flower'
    character = 'F'
    layer = "tiles"

    def __init__(self):
        self.health = Health(1, ArmorKind.Organic)
        self.color = random.choice([Colors.Cyan, Colors.Default, Colors.Magenta])
