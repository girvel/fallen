from typing import Any

from ecs import DynamicEntity

from src.engine.naming.name import Name, CompositeName
from src.engine.output.colors import ColorPair, red
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.query import Q


class Body(DynamicEntity):
    character = '&'
    color = ColorPair(red)
    layer = "tiles"

    def __init__(
        self, parent_name: Name, items: list[Any] = None,
        **attributes,
    ):
        self.name = CompositeName(Name({
            "им": "тело",
            "ро": "тела",
            "да": "тело",
            "ви": "тела",
            "тв": "телом",
            "пр": "теле",
        }), Name(f"{parent_name:ро}"))

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
