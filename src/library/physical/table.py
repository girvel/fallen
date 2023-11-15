from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.naming.name import Name
from src.engine.output.colors import yellow, ColorPair

from src.systems.ai import Kind


class Table(DynamicEntity):
    name = Name("стол")
    character = '"'
    color = ColorPair(yellow)
    classifiers = {Kind.Table}
    layer = "physical"

    boring_flag = None

    def __init__(self):
        self.health = Health(35, ArmorKind.Wood)
