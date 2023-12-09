import logging
from abc import ABCMeta
from dataclasses import dataclass
from typing import Any, Protocol, TypeGuard, TypeVar, get_type_hints

from ecs import Entity, exists

from src.engine.language.name import Name
from src.engine.rails.rails_api import RailsApi, Script
from src.lib.toolkit import assert_attributes


T = TypeVar("T")
def match_annotation(instance: Any, type_annotation: type[T]) -> TypeGuard[T]:
    return isinstance(instance, type_annotation) and exists(instance)


class SceneDefinition(Protocol):
    def run(self, rails: "RailsBase") -> Script:
        ...


@dataclass
class SceneRun:
    name: str
    generator: Script


@dataclass(eq=False)
class Scene:
    name: str
    enabled: bool
    definition: SceneDefinition

    @classmethod
    def new(cls, enabled: bool = True):
        def decorator(definition_class: type[SceneDefinition]) -> "Scene":
            return cls(definition_class.__name__, enabled, definition_class())

        return decorator


class RailsBase(RailsApi, Entity, metaclass=ABCMeta):
    characters: dict[str, Any]

    name = Name("Рельсы")
    rails_flag = None

    def __init__(self, level, ms, genesis):
        RailsApi.__init__(self, level, ms, genesis)
        self.__post_init__()
        assert_attributes(self, ["characters"])

        self.scenes = [
            scene
            for scene in vars(type(self)).values()
            if isinstance(scene, Scene)
        ]

        self.current_scenes: list[SceneRun] = []

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

    def __post_init__(self):
        ...

    def _get_character(self, name: str) -> Any:
        result = self.characters[name]
        return result() if callable(result) else result

    def get_effect(self):
        for scene in self.scenes:
            if not scene.enabled: continue  # TODO OPT: remove disabled scenes from the list?

            for character_name, character_type in get_type_hints(scene.definition).items():
                if not match_annotation(character := self._get_character(character_name), character_type): break
                setattr(scene.definition, character_name, character)
            else:
                if not hasattr(scene.definition, "start_predicate") or scene.definition.start_predicate(self):
                    self.current_scenes.append(SceneRun(scene.name, scene.definition.run(self)))
                    logging.info(f"Starting the scene {scene.name}")

        total_effect = {}
        stop_signal = object()

        for scene_run in self.current_scenes.copy():
            if (effect := next(scene_run.generator, stop_signal)) is not stop_signal:
                total_effect |= effect or {}
            else:
                self.current_scenes.remove(scene_run)
                logging.info(f"Ending the scene {scene_run.name}")

        return total_effect


