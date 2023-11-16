import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan, red, magenta


class Flower(DynamicEntity):
    name = Name("цветок")
    character = 'F'
    layer = "tiles"

    def __init__(self):
        self.sex = random.choice(["male", "female", "mercury"])
        self.health = Health(1, ArmorKind.Organic)
        self.color = random.choice([ColorPair(cyan), ColorPair(red), ColorPair(magenta)])
