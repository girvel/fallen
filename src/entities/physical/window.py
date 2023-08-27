from ecs import OwnedEntity

from src.systems.acting.damage import Health, ArmorKind


class Window(OwnedEntity):
    name = 'Window'
    character = '='

    def __init__(self):
        self.health = Health(10, ArmorKind.Glass)
