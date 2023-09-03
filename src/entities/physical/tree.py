import random

from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors
from src.systems.acting.damage import Health, ArmorKind


class Tree(OwnedEntity):
    name = 'Tree'
    character = 'T'
    color = Colors.Green
    solid_flag = None

    def __init__(self):
        self.health = Health(random.randrange(250, 2000), ArmorKind.Wood)
