from ecs import OwnedEntity


class Hades(OwnedEntity):
    name = 'hades'

    def __init__(self):
        self.entities_to_destroy = set()
