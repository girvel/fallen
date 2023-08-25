from ecs import OwnedEntity

from src.systems.acting.attack import Health, ArmorKind


class Bed(OwnedEntity):
    name = 'bed'
    character = '='

    def __init__(self):
        self.health = Health(10, ArmorKind.Wood)
