import logging
from abc import ABCMeta
from dataclasses import dataclass
from typing import Any

from ecs import Entity

from src.engine.language.name import Name
from src.engine.rails.rails_api import RailsApi, Script
from src.engine.rails.scene import Scene


@dataclass
class SceneRun:
    base: Scene
    generator: Script
    tick_counter: int = 0


class RailsBase(RailsApi, Entity, metaclass=ABCMeta):
    characters: dict[str, Any]

    name = Name("rails")
    rails_flag = None

    def __init__(self, level, hades, genesis):
        RailsApi.__init__(self, level, hades, genesis)
        self.__post_init__()

        self.scenes = list(sorted(
            (scene
             for scene in vars(type(self)).values()
             if isinstance(scene, Scene)),
            key=lambda scene: -scene.priority.value
        ))

        self.current_scenes: list[SceneRun] = []
        self.current_cutscene: SceneRun | None = None

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

    def __post_init__(self):
        ...

    def get_character(self, name: str) -> Any:
        result = self.characters[name]
        return result() if callable(result) else result

    def get_effect(self):
        for scene in self.scenes:
            if (self.current_cutscene is None or scene.priority.value == 0) and scene.start_predicate(self):
                run = SceneRun(scene, scene.run(self))
                self.current_scenes.append(run)
                logging.info(f"Starting the scene {scene.name}")

                if scene.priority.value != 0:
                    self.current_cutscene = run

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

                if self.current_cutscene is scene_run:
                    self.current_cutscene = None

        return total_effect

    def run_task(self, *args, **kwargs):
        def decorator(f):
            @Scene.new(name=f.__name__)
            class task:
                def run(self_task, rails: "RailsBase"):
                    yield from f(*args, **kwargs)
                    self.scenes.remove(task)

            self.scenes.append(task)
            return f

        return decorator
