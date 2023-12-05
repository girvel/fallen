from typing import Any

from ecs import Entity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, red
from src.lib.query import Q
from src.library.abstract.material import Material
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


class Body(Material):
    base_name = Name.auto("тело")

    character = '&'
    color = ColorPair(red)
    layer = "tiles"

    boring_flag = None

    def __post_init__(self, parent_name: Name, items: list[Any] = None):
        self.name = self.base_name.concat(f" {parent_name:ро}")
        # TODO abstract body

        self.items = items or []


def body_factory(base: Any, _hades: Hades, genesis: Genesis) -> bool:
    items = []

    if hasattr(base, "weapon"):
        items.append(base.weapon)

    genesis.entities_to_create.add(Body(
        base.name, items=items, sex=~Q(base).sex, p=base.p, level=base.level
    ))

    return True
