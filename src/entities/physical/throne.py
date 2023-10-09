from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.name import Name
from src.engine.output.colors import ColorPair, yellow


class Throne(DynamicEntity):
    name = Name("Throne")
    layer = "physical"
    character = 't'
    color = ColorPair(yellow)

    def __init__(self):
        self.health = Health(700, ArmorKind.Wood)
