from ecs import DynamicEntity

from src.engine.output.colors import ColorPair, green


class Grass(DynamicEntity):
    name = 'Grass'
    character = ','
    color = ColorPair(green)
    layer = "tiles"
