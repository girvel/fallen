from dataclasses import dataclass
from enum import Enum
from typing import get_type_hints, TypeVar, Any, TypeGuard, Protocol, TYPE_CHECKING, get_origin, Annotated, get_args

from ecs import exists

from src.engine.rails.rails_api import Script, Lock
from src.lib.query import Q

if TYPE_CHECKING:
    from src.engine.rails.rails_base import RailsBase


keep_ai = object()
keep_death = object()
maybe_exists = object()
not_required = object()


class Priority(Enum):
    script = 0  # scripts do not block other scenes
    sideline = 1
    mainline = 2


@dataclass(eq=False)
class Scene:
    name: str
    enabled: bool
    reoccurring: bool
    priority: Priority
    timeout: int

    _definition: "SceneDefinition"
    _characters_required: list["CharacterRequirement"]

    @classmethod
    def new(cls, *,
        enabled: bool = True, reoccurring: bool = False, priority: Priority = Priority.script,
        timeout: int = 5_000, name: str | None = None,
    ):
        def decorator(definition_class: type[SceneDefinition]) -> "Scene":
            return cls(
                name=name or definition_class.__name__,
                enabled=enabled,
                reoccurring=reoccurring,
                priority=priority,
                timeout=timeout,
                _definition=definition_class(),
                _characters_required=[
                    requirement
                    for name_, annotation
                    in get_type_hints(definition_class, include_extras=True).items()
                    if (requirement := CharacterRequirement.from_annotation(name_, annotation)) is not None
                ],
            )

        return decorator

    def start_predicate(self, rails: "RailsBase") -> bool:
        if not self.enabled: return False

        for requirement in self._characters_required:
            character = rails.get_character(requirement.name)
            if not requirement.matches(character, rails):
                return False

            setattr(self._definition, requirement.name, character)

        if hasattr(self._definition, "start_predicate"):
            return self._definition.start_predicate(rails)

        return True

    def run(self, rails: "RailsBase"):
        if not self.reoccurring: self.enabled = False

        ai_locks = []
        death_locks = []

        for requirement in self._characters_required:
            if (character_or_list := getattr(self._definition, requirement.name)) is None: continue

            for character in (character_or_list if isinstance(character_or_list, list) else [character_or_list]):
                args = (character, Lock(self))

                if requirement.needs_ai_lock and not hasattr(~Q(character).ai, "cutscene_aware_flag"):
                    ai_locks.append(args)
                    rails.lock_complex_ai(*args)

                if requirement.needs_death_lock:
                    death_locks.append(args)
                    rails.lock_dying(*args)

        yield from self._definition.run(rails)

        for args in ai_locks:
            rails.unlock_complex_ai(*args)

        for args in death_locks:
            rails.unlock_dying(*args)



@dataclass
class CharacterRequirement:
    name: str
    python_type: type

    needs_ai_lock: bool
    needs_death_lock: bool
    has_to_exist: bool

    @classmethod
    def from_annotation(cls, name: str, annotation: type) -> "CharacterRequirement | None":
        if get_origin(annotation) == Annotated:
            python_type, *args = get_args(annotation)
        else:
            python_type = annotation
            args = []

        if not_required in args: return

        return cls(
            name=name,
            python_type=python_type,
            needs_ai_lock=keep_ai not in args,
            needs_death_lock=keep_death not in args,
            has_to_exist=maybe_exists not in args,
        )

    def matches(self, instance, rails: "RailsBase"):
        return self._matches(instance, rails, self.python_type)

    def _matches(self, instance, rails, type_override):
        if get_origin(type_override) is list:
            return all(self._matches(element, rails, get_args(type_override)[0]) for element in instance)

        return (
            isinstance(instance, type_override) and
            (not self.has_to_exist or exists(instance)) and
            (instance.level == rails.level)
        )



class SceneDefinition(Protocol):
    def run(self, rails: "RailsBase") -> Script:
        ...
