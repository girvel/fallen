import random

from ecs import DynamicEntity

from src.engine.naming.library import last_names, reserved_names
from src.engine.naming.name import Name


class House(DynamicEntity):
    name = Name("Дом")

    @classmethod
    def from_markup(cls,
        start: list[int], end: list[int], entrance: list[int],
        reserved_for: str | None = None
    ):
        return cls(
            house_borders=(tuple(start), tuple(end)),
            entrance=tuple(entrance),
            family_names=random.choice(last_names) if reserved_for is None else reserved_names[reserved_for],
            reserved_for=reserved_for,
        )
