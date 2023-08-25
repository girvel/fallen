from ecs import OwnedEntity

from src.entities.special.screen import Colors
from src.systems.acting.attack import Health, ArmorKind


class SlashWall(OwnedEntity):
    name = 'Wall'
    character = '\\'
    color = Colors.Yellow

    def __init__(self):
        self.health = Health(2000, ArmorKind.Wood)
