from functools import partial
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

    def __post_init__(self, core_name: Name, parent_name: Name, sex: str | None, items: list[Any] = None):
        self.name = core_name.concat(f" {parent_name:ро}")
        self.sex = sex
        # TODO abstract body

        self.items = items or []


def body_factory(base: Any, _hades: Hades, genesis: Genesis):
    items = []

    if hasattr(base, "damage_source"):
        items.append(base.damage_source)

    genesis.push(Body(
        core_name=Name.auto("тело" if base.health.maximum > 6 else "тельце"),
        parent_name=base.name, items=items, sex=~Q(base).sex, p=base.p, level=base.level
    ))


def generate_body_factory(base: Any):
    return partial(body_factory, base)
