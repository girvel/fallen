from ecs import DynamicEntity

from src.engine.naming.name import Name


class House(DynamicEntity):
    name = Name("Дом")

    def __init__(self, start, end, entrance):
        self.house_borders = (tuple(start), tuple(end))  # TODO figure out how to do this at loading markup
        self.entrance = tuple(entrance)
