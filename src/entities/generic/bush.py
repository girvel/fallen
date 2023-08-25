from ecs import OwnedEntity, Entity

from src.entities.special.screen import Colors
from src.systems.acting.attack import ArmorKind, Health


class Bush(OwnedEntity):
    name = 'Bush'
    character = 'b'
    color = Colors.Green
    solid_flag = None

    def __init__(self):
        self.health = Health(20, ArmorKind.Organic)
