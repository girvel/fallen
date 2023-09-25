from ecs import DynamicEntity


class Hades(DynamicEntity):
    name = 'hades'

    def __init__(self):
        self.entities_to_destroy = set()
