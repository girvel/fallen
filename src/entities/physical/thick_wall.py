from ecs import OwnedEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import Colors



class ThickWall(OwnedEntity):
    name = 'Thick wall'
    character = '#'
    color = Colors.Yellow
    solid_flag = None

    def __init__(self):
        self.health = Health(10000, ArmorKind.Stone)
