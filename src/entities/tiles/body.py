from typing import Any

from ecs import DynamicEntity

from src.engine.output.colors import Colors
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades


class Body(DynamicEntity):
    character = '&'
    color = Colors.Red
    layer = "tiles"

    def __init__(
        self, name: str = "Body", items: list[Any] = None,
        **attributes,
    ):
        self.name = name
        self.items = items or []

        super().__init__(**attributes)


def body_factory(base: DynamicEntity, hades: Hades, genesis: Genesis):
    items = []

    if hasattr(base, "weapon"):
        items.append(base.weapon)

    genesis.entities_to_create.add(Body(
        name=f"Body of {base.name}", items=items, p=base.p, level=base.level
    ))

    return True
