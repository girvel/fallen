from dataclasses import dataclass
from typing import get_type_hints, TypeVar, Any, TypeGuard, Protocol, TYPE_CHECKING, get_origin, Annotated, get_args

from ecs import exists

from src.engine.rails.rails_api import Script
from src.lib.query import Q

if TYPE_CHECKING:
    from src.engine.rails.rails_base import RailsBase


T = TypeVar("T")
def match_annotation(instance: Any, type_annotation: type[T]) -> TypeGuard[T]:
    if get_origin(type_annotation) == Annotated:
        return match_annotation(instance, get_args(type_annotation)[0])

    return isinstance(instance, type_annotation) and exists(instance)

def needs_ai_lock(type_annotation: type) -> bool:
    return (
        get_origin(type_annotation) != Annotated or
        keep_ai not in get_args(type_annotation)[1:]
    )


class SceneDefinition(Protocol):
    def run(self, rails: "RailsBase") -> Script:
        ...

keep_ai = object()


@dataclass(eq=False)
class Scene:
    name: str
    enabled: bool
    reoccurring: bool
    _definition: SceneDefinition

    @classmethod
    def new(cls, enabled: bool = True, reoccurring: bool = False):
        def decorator(definition_class: type[SceneDefinition]) -> "Scene":
            return cls(definition_class.__name__, enabled, reoccurring, definition_class())

        return decorator

    def start_predicate(self, rails: "RailsBase") -> bool:
        if not self.enabled: return False

        # TODO bug when a method in the definition is annotated
        for character_name, character_type in get_type_hints(self._definition).items():
            if not match_annotation(character := rails._get_character(character_name), character_type): return False
            setattr(self._definition, character_name, character)

        if hasattr(self._definition, "start_predicate"):
            return self._definition.start_predicate(self)

        return True

    def run(self, rails: "RailsBase"):
        if not self.reoccurring: self.enabled = False

        locks = [
            (character, rails.lock_complex_ai(character))
            for character_name, character_type in get_type_hints(self._definition, include_extras=True).items()
            if (character := getattr(self._definition, character_name)) is not None
            and needs_ai_lock(character_type)
        ]

        yield from self._definition.run(rails)

        for character, lock in locks:
            rails.unlock_complex_ai(character, lock)
