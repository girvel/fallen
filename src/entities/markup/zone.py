from ecs import DynamicEntity

from src.engine.naming.name import Name


class Zone(DynamicEntity):
    @classmethod
    def from_markup(cls, name, center, attractiveness):
        return cls(
            name=Name(name),
            center=tuple(center),
            attractiveness=attractiveness,
        )
