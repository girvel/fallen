from ecs import OwnedEntity


class House(OwnedEntity):
    name = 'house'

    def __init__(self, start, end, entrance):
        self.house_borders = (tuple(start), tuple(end))  # TODO figure out how to do this at loading markup
        self.entrance = tuple(entrance)
