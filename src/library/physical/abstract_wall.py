from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.naming.name import Name
from src.engine.output.colors import ColorPair, yellow


class AbstractWall(DynamicEntity):
    name = Name("стена")
    character = None
    color = ColorPair(yellow)
    layer = "physical"

    boring_flag = None

    def __init__(self, **attributes):
        self.health = Health(2000, ArmorKind.Wood)
        super().__init__(**attributes)
