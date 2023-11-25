from ecs import DynamicEntity

from src.engine.language.name import Name
from src.lib.vector import int2


class Zone(DynamicEntity):
    name: Name
    center: int2
    attractiveness: float
    is_social: bool

    @classmethod
    def from_markup(cls, name: str | dict, center, attractiveness: float, is_social: bool = False):
        return cls(
            name=Name.auto(name) if isinstance(name, str) else Name(name),
            center=tuple(center),
            attractiveness=attractiveness,
            is_social=is_social,
        )
