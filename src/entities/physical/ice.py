from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import white, blue, ColorPair


class Ice(DynamicEntity):
    name = 'Ice'
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    def __init__(self):
        self.health = Health(1000, ArmorKind.Ice)
