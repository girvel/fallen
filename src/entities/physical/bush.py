from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.output.colors import Colors



class Bush(DynamicEntity):
    name = 'Bush'
    character = 'b'
    color = Colors.Green
    solid_flag = None
    layer = "physical"

    def __init__(self):
        self.health = Health(20, ArmorKind.Organic)
