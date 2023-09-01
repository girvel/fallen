from ecs import OwnedEntity


class Zone(OwnedEntity):
    def __init__(self, name, center):
        self.name = name
        self.center = tuple(center)  # TODO figure out how to do this at loading markup
