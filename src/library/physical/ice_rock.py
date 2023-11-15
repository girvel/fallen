from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.naming.name import Name
from src.engine.output.colors import white, blue, ColorPair


class IceRock(DynamicEntity):
    name = Name("ледяная глыба")
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    boring_flag = None

    def __init__(self):
        self.health = Health(1000, ArmorKind.Ice)
