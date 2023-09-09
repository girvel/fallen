from ecs import OwnedEntity

from src.engine.acting.damage import ArmorKind, Health


class Window(OwnedEntity):
    name = 'Window'
    character = '='

    def __init__(self):
        self.health = Health(10, ArmorKind.Glass)
