from ecs import OwnedEntity

from src.entities.special.screen import Colors


class SlashWall(OwnedEntity):
    name = 'inclined_wall'
    character = '\\'
    color = Colors.Yellow
