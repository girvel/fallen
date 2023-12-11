from dataclasses import dataclass
from typing import get_type_hints, TypeVar, Any, TypeGuard, Protocol, TYPE_CHECKING

from ecs import exists

from src.engine.rails.rails_api import Script
from src.lib.query import Q

if TYPE_CHECKING:
    from src.engine.rails.rails_base import RailsBase


T = TypeVar("T")
def match_annotation(instance: Any, type_annotation: type[T]) -> TypeGuard[T]:
    return isinstance(instance, type_annotation) and exists(instance)


class SceneDefinition(Protocol):
    def run(self, rails: "RailsBase") -> Script:
        ...


@dataclass(eq=False)
class Scene:
    name: str
    enabled: bool
    _definition: SceneDefinition

    @classmethod
    def new(cls, enabled: bool = True):
        def decorator(definition_class: type[SceneDefinition]) -> "Scene":
            return cls(definition_class.__name__, enabled, definition_class())

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
        locks = [
            (character, rails.lock_complex_ai(character))
            for character_name, _ in get_type_hints(self._definition).items()
            if (character := getattr(self._definition, character_name)) is not None
            and not hasattr(character, "player_flag")
        ]

        yield from self._definition.run(rails)

        for character, lock in locks:
            rails.unlock_complex_ai(character, lock)
