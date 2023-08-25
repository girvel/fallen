from ecs import OwnedEntity

from src.entities.special.screen import Colors


class SlashWall(OwnedEntity):
    character = '\\'

    def __init__(self):
        super().__init__(name='inclined_wall', color=Colors.Yellow)