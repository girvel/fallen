from ecs import OwnedEntity

from src.entities.special.screen import Colors
from src.systems.acting.attack import Health, ArmorKind


class ThickWall(OwnedEntity):
    name = 'Thick wall'
    character = '#'
    color = Colors.Yellow
    solid_flag = None

    def __init__(self):
        self.health = Health(10000, ArmorKind.Stone)
