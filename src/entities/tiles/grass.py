from ecs import OwnedEntity

from src.engine.io.colors import Colors


class Grass(OwnedEntity):
    name = 'Grass'
    character = ','
    color = Colors.Green
