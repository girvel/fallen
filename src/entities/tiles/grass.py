from ecs import OwnedEntity

from src.entities.ais.io import Colors


class Grass(OwnedEntity):
    name = 'Grass'
    character = ','
    color = Colors.Green
