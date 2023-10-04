from ecs import DynamicEntity

from src.engine.output.colors import Colors


class Water(DynamicEntity):
    name = 'Water'
    character = '~'
    color = Colors.WhiteOnBlue
    layer = "physical"
