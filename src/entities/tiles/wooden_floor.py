from ecs import OwnedEntity

from src.engine.output.colors import Colors


class WoodenFloor(OwnedEntity):
    name = 'Wooden floor'
    character = '_'
    color = Colors.Yellow
