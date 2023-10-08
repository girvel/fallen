from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import ColorPair, yellow


class ThickWall(DynamicEntity):
    name = 'Thick wall'
    character = '#'
    color = ColorPair(yellow)
    solid_flag = None
    layer = "physical"

    def __init__(self, **attributes):
        self.health = Health(10000, ArmorKind.Stone)
        super().__init__(**attributes)
