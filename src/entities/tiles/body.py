from typing import Any

from ecs import OwnedEntity

from src.engine.io.colors import Colors
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level


class Body(OwnedEntity):
    character = '&'
    color = Colors.Red
    layer = "tiles"

    def __init__(self, name: str = "Body", items: list[Any] = None):
        self.name = name
        self.items = items or []


def body_factory(base: OwnedEntity, hades: Hades, genesis: Genesis, level: Level):
    items = []

    if hasattr(base, "weapon"):
        items.append(base.weapon)

    genesis.entities_to_create.add(level.put(base.p, Body(name=f"Body of {base.name}", items=items)))
