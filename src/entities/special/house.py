from ecs import OwnedEntity


class House(OwnedEntity):
    name = 'house'

    def __init__(self, start, end, entrance):
        self.house_borders = (tuple(start), tuple(end))
        self.entrance = tuple(entrance)
