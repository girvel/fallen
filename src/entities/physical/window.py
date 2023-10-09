from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.name import Name


class Window(DynamicEntity):
    name = Name("Окно")
    character = '='
    layer = "physical"

    def __init__(self):
        self.health = Health(10, ArmorKind.Glass)
