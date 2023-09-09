import random

from ecs import OwnedEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.io.colors import Colors



class Tree(OwnedEntity):
    name = 'Tree'
    character = 'T'
    color = Colors.Green
    solid_flag = None

    def __init__(self):
        self.health = Health(random.randrange(250, 2000), ArmorKind.Wood)
