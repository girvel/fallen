from ecs import OwnedEntity

from src.entities.ais.io import Colors
from src.systems.acting.attack import Health, ArmorKind


class AbstractWall(OwnedEntity):
    name = 'Wall'
    character = None
    color = Colors.Yellow
    solid_flag = None

    def __init__(self):
        self.health = Health(2000, ArmorKind.Wood)
