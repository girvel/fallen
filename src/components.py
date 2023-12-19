from dataclasses import dataclass, field
from typing import Any, Protocol, TYPE_CHECKING, runtime_checkable

from ecs import Entity

from src.engine.language.name import Name

if TYPE_CHECKING:
    from numpy import ndarray, dtype

    from src.engine.acting.action import Action
    from src.engine.acting.damage import Health
    from src.engine.ai import Senses
    from src.engine.output.colors import ColorPair
    from src.lib.vector.vector import int2
    from src.library.special.level import Level


# GENERAL PROTOCOLS #

class Blinking(Protocol):
    blink_colors: "list[ColorPair]"
    blink_colors_i: "int"
    is_blinking: "bool"

class Counting(Protocol):
    tick_counter: "int"

@runtime_checkable
class Positioned(Protocol):
    level: "Level"
    layer: "str"
    p: "int2"

class Liquid(Positioned):
    liquid_height: "int"

class RailsComponent(Protocol):
    rails_flag: "None"
    level: "Level"

    def get_effect(self) -> "dict[Any, Action | None]":
        ...

class GridContainer(Protocol):
    grids: "dict[str, tuple[int2, list[list[Positioned]]]]"
    transparency_cache: "ndarray[Any, dtype[int]]"
    rails: "RailsBase | None"

class Sentient(Positioned):
    ai: "Any"

class Killer(Protocol):
    last_killed: "list[Any]"

class Healthy(Protocol):
    health: "Health"

class Actor(Protocol):
    act: "Action"

class DyingWithChance(Protocol):
    death_chance: "float"

class Sound(Protocol):
    sound_flag: "None"


# SPECIAL PROTOCOLS #

@dataclass
class Genesis(Entity):
    name: Name = field(default_factory=lambda: Name("Генезис"))
    entities_to_create: list[Any] = field(default_factory=list)

    def push(self, entity):
        self.entities_to_create.append(entity)
        return entity

    __hash__ = object.__hash__

@dataclass
class Hades(Entity):
    name: Name = field(default_factory=lambda: Name("Хейдс"))
    entities_to_destroy: list[Any] = field(default_factory=list)

    def push(self, entity):
        self.entities_to_destroy.append(entity)
        return entity

    __hash__ = object.__hash__
