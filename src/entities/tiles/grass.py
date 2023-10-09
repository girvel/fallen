from ecs import DynamicEntity

from src.engine.name import Name
from src.engine.output.colors import ColorPair, green


class Grass(DynamicEntity):
    name = Name("Grass")
    character = ','
    color = ColorPair(green)
    layer = "tiles"
