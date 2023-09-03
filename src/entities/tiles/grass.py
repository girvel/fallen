from ecs import OwnedEntity

from src.entities.ais.iolib.colors import Colors


class Grass(OwnedEntity):
    name = 'Grass'
    character = ','
    color = Colors.Green
