import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.naming.name import Name
from src.engine.output.colors import ColorPair, green, yellow


class Tree(DynamicEntity):
    name = Name("дерево")
    character = 'T'
    color = ColorPair(yellow, green)
    solid_flag = None
    layer = "physical"

    def __init__(self):
        self.health = Health(random.randrange(250, 2000), ArmorKind.Wood)
