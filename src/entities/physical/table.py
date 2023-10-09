from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.name import Name
from src.engine.output.colors import yellow, ColorPair

from src.systems.ai import Kind


class Table(DynamicEntity):
    name = Name("Стол")
    character = '"'
    color = ColorPair(yellow)
    classifiers = {Kind.Table}
    layer = "physical"

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
