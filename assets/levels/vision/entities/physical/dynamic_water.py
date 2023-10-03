from ecs import DynamicEntity

from src.engine.output.colors import Colors


class DynamicWater(DynamicEntity):
    name = 'Water'
    character = '~'
    color = Colors.Blue
    flow_height = 5
