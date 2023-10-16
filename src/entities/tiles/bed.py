from ecs import DynamicEntity

from src.engine.name import Name
from src.engine.output.colors import ColorPair, cyan


class Bed(DynamicEntity):
    name = Name("кровать")
    character = 'B'
    color = ColorPair(cyan)
    layer = "tiles"
