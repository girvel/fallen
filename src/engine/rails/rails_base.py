import logging
from abc import ABCMeta
from dataclasses import dataclass
from typing import Any

from ecs import Entity

from src.engine.language.name import Name
from src.engine.rails.rails_api import RailsApi, Script
from src.engine.rails.scene import Scene, Priority
from src.lib.toolkit import assert_attributes


@dataclass
class SceneRun:
    base: Scene
    generator: Script
    tick_counter: int = 0


class RailsBase(RailsApi, Entity, metaclass=ABCMeta):
    characters: dict[str, Any]

    name = Name("Рельсы")
    rails_flag = None

    def __init__(self, level, ms, genesis):
        RailsApi.__init__(self, level, ms, genesis)
        self.__post_init__()
        assert_attributes(self, ["characters"])

        self.scenes = list(sorted(
            (scene
             for scene in vars(type(self)).values()
             if isinstance(scene, Scene)),
            key=lambda scene: -scene.priority.value
        ))

        self.current_scenes: list[SceneRun] = []
        self.in_cutscene = False

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

    def __post_init__(self):
        ...

    def _get_character(self, name: str) -> Any:
        result = self.characters[name]
        return result() if callable(result) else result

    def get_effect(self):
        for scene in self.scenes:
            if (not self.in_cutscene or scene.priority.value == 0) and scene.start_predicate(self):
                self.current_scenes.append(SceneRun(scene, scene.run(self)))
                logging.info(f"Starting the scene {scene.name}")

                if scene.priority is not None:
                    self.in_cutscene = True

        total_effect = {}
        stop_signal = object()

        for scene_run in self.current_scenes.copy():
            if scene_run.tick_counter >= scene_run.base.timeout:
                logging.warning(f"Scene {scene_run.base.name} timed out after {scene_run.tick_counter} ticks")
                scene_run.generator = self.end_cutscene()
                scene_run.tick_counter = -2

            if (effect := next(scene_run.generator, stop_signal)) is not stop_signal:
                total_effect |= effect or {}
                scene_run.tick_counter += 1
            else:
                self.current_scenes.remove(scene_run)
                logging.info(f"Ending the scene {scene_run.base.name}")

                if scene_run.base.priority.value != 0:
                    self.in_cutscene = False

        return total_effect
