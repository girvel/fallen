import random

from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import Colors



class Tree(DynamicEntity):
    name = 'Tree'
    character = 'T'
    color = Colors.Green
    solid_flag = None
    layer = "physical"

    def __init__(self):
        self.health = Health(random.randrange(250, 2000), ArmorKind.Wood)
