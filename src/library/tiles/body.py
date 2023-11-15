from typing import Any

from ecs import DynamicEntity

from src.engine.naming.name import Name, CompositeName
from src.engine.output.colors import ColorPair, red
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.lib.query import Q


class Body(DynamicEntity):
    base_name = Name.auto("тело")

    character = '&'
    color = ColorPair(red)
    layer = "tiles"

    def __init__(
        self, parent_name: Name, items: list[Any] = None,
        **attributes,
    ):
        self.name = self.base_name.concat(f" {parent_name:ро}")
        # TODO abstract body

        self.items = items or []

        super().__init__(**attributes)


def body_factory(base: DynamicEntity, hades: Hades, genesis: Genesis):
    items = []

    if hasattr(base, "weapon"):
        items.append(base.weapon)

    genesis.entities_to_create.add(Body(
        base.name, items=items, sex=~Q(base).sex, p=base.p, level=base.level
    ))

    return True
