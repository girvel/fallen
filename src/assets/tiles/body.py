from typing import Any

from ecs import Entity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, red
from src.lib.query import Q
from src.assets.abstract.material import Material
from src.components import Genesis, Hades


class Body(Material):
    base_name = Name.auto("тело")

    character = '&'
    color = ColorPair(red)
    layer = "tiles"

    boring_flag = None

    def __post_init__(self, parent_name: Name, sex: str | None, items: list[Any] = None):
        self.name = self.base_name.concat(f" {parent_name:ро}")
        self.sex = sex
        # TODO abstract body

        self.items = items or []


def generate_body_factory(base: Any):
    def result(_hades: Hades, genesis: Genesis) -> bool:
        items = []

        if hasattr(base, "weapon"):
            items.append(base.weapon)

        genesis.push(Body(
            parent_name=base.name, items=items, sex=~Q(base).sex, p=base.p, level=base.level
        ))

    return result
