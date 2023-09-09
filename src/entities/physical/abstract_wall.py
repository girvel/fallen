from ecs import OwnedEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.io.colors import Colors



class AbstractWall(OwnedEntity):
    name = 'Wall'
    character = None
    color = Colors.Yellow
    solid_flag = None

    def __init__(self):
        self.health = Health(2000, ArmorKind.Wood)
