from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health
from src.engine.language.name import Name


class Window(DynamicEntity):
    name = Name("окно")
    character = '='
    layer = "physical"

    boring_flag = None

    def __init__(self):
        self.health = Health(10, ArmorKind.Glass)
