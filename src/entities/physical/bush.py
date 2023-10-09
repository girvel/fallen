from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.name import Name
from src.engine.output.colors import ColorPair, green


class Bush(DynamicEntity):
    name = Name("Bush")
    character = 'b'
    color = ColorPair(green)
    solid_flag = None
    layer = "physical"

    def __init__(self):
        self.health = Health(20, ArmorKind.Organic)
