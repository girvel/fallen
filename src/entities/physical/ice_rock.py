from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.name import Name
from src.engine.output.colors import white, blue, ColorPair


class IceRock(DynamicEntity):
    name = Name("Ледяная глыба")
    character = 'I'
    color = ColorPair(blue, white)
    layer = "physical"

    def __init__(self, **attributes):
        self.health = Health(1000, ArmorKind.Ice)
        super().__init__(**attributes)
