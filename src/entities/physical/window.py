from ecs import DynamicEntity

from src.engine.acting.damage import ArmorKind, Health


class Window(DynamicEntity):
    name = 'Window'
    character = '='
    layer = "physical"

    def __init__(self):
        self.health = Health(10, ArmorKind.Glass)
