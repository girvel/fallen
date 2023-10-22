from ecs import DynamicEntity

from src.engine.naming.name import Name


class House(DynamicEntity):
    name = Name("Дом")

    @classmethod
    def from_markup(cls, start, end, entrance):
        return cls(
            house_borders=(tuple(start), tuple(end)),
            entrance=tuple(entrance),
        )
