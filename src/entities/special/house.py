from ecs import OwnedEntity


class House(OwnedEntity):
    name = 'house'

    def __init__(self, start, end):
        self.house_borders = (start, end)
