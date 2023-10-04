from ecs import DynamicEntity

from src.engine.output.colors import Colors


class Grass(DynamicEntity):
    name = 'Grass'
    character = ','
    color = Colors.Green
    layer = "tiles"
