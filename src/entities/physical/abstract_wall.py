from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import ColorPair, yellow


class AbstractWall(DynamicEntity):
    name = 'Wall'
    character = None
    color = ColorPair(yellow)
    solid_flag = None
    layer = "physical"

    def __init__(self):
        self.health = Health(2000, ArmorKind.Wood)
