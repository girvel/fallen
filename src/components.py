from dataclasses import dataclass, field
from typing import Any, Protocol, TYPE_CHECKING, runtime_checkable

from ecs import Entity

from src.engine.language.name import Name

if TYPE_CHECKING:
    from src.engine.acting.action import Action
    from src.engine.output.colors import ColorPair
    from src.lib.vector.vector import int2
    from src.assets.special.level import Level
    from src.lib.time import Time


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

class Sentient(Positioned):
    ai: Any

class Actor(Protocol):
    act: "Action"

class Killer(Protocol):
    last_killed: list[Any]

class Damaged(Protocol):
    last_damaged_by: list[Any]

class DyingWithChance(Protocol):
    death_chance: float

class Sound(Protocol):
    sound_flag: None

class Attentive(Protocol):
    attention_boost: int

class TimeAware(Protocol):
    time: "Time"


# SPECIAL PROTOCOLS #

@dataclass
class Genesis(Entity):
    name: Name = field(default_factory=lambda: Name("Генезис"))
    entities_to_create: list[Any] = field(default_factory=list)

    def push(self, entity):
        if entity not in self.entities_to_create:
            self.entities_to_create.append(entity)
        return entity

    __hash__ = object.__hash__

@dataclass
class Hades(Entity):
    name: Name = field(default_factory=lambda: Name("Хейдс"))
    entities_to_destroy: list[Any] = field(default_factory=list)

    def push(self, entity):
        if entity not in self.entities_to_destroy:
            self.entities_to_destroy.append(entity)
        return entity

    __hash__ = object.__hash__
