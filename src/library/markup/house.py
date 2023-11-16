import random

from ecs import DynamicEntity

from src.engine.language.library import last_names, reserved_names, Sex
from src.engine.language.name import Name
from src.lib.vector import int2


class House(DynamicEntity):
    name: Name = Name.auto("дом")
    house_borders: tuple[int2, int2]
    entrance: int2
    family_names: dict[Sex, Name]
    reserved_for: str

    @classmethod
    def from_markup(
        cls, start: list[int], end: list[int], entrance: list[int],
        reserved_for: str | None = None
    ):
        family_names = random.choice(last_names) if reserved_for is None else reserved_names[reserved_for]

        return cls(
            name=Name.auto("Дом").concat(f" семьи {family_names['male']}"),
            house_borders=(tuple(start), tuple(end)),
            entrance=tuple(entrance),
            family_names=family_names,
            reserved_for=reserved_for,
        )
