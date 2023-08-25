from ecs import OwnedEntity

from src.entities.special.screen import Colors


class SlashWall(OwnedEntity):
    name = 'Wall'
    character = '\\'
    color = Colors.Yellow
