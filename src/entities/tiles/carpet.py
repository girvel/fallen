from ecs import DynamicEntity

from src.engine.output.colors import Colors


class Carpet(DynamicEntity):
    name = 'Carpet'
    character = '`'
    color = Colors.Magenta
