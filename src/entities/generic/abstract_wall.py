from ecs import OwnedEntity

from src.entities.special.io import Colors
from src.systems.acting.attack import Health, ArmorKind


class AbstractWall(OwnedEntity):
    name = 'AbstractWall'
    character = None
    color = Colors.Yellow
    solid_flag = None

    def __init__(self):
        self.health = Health(2000, ArmorKind.Wood)
