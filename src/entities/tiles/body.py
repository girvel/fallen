from typing import Any, Optional

from ecs import OwnedEntity

from src.engine.output.colors import Colors
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.lib.vector import int2


class Body(OwnedEntity):
    character = '&'
    color = Colors.Red
    layer = "tiles"

    def __init__(self, name: str = "Body", items: list[Any] = None, p: Optional[int2] = None):
        self.name = name
        self.items = items or []

        if p is not None:
            self.p = p


def body_factory(base: OwnedEntity, hades: Hades, genesis: Genesis, level: Level):
    items = []

    if hasattr(base, "weapon"):
        items.append(base.weapon)

    genesis.entities_to_create.add(Body(name=f"Body of {base.name}", items=items, p=base.p))
