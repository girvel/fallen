import functools
import logging
from collections import namedtuple
from dataclasses import dataclass
from typing import Callable

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.lib.vector import floordiv2, sub2


class RailsBase(DynamicEntity):
    name = "Rails"
    rails_flag = None

    def __init__(self, level, ms):
        self.scenes = []
        self.current_scenes = []

        for p in vars(type(self)).values():
            if not isinstance(p, PreScene): continue
            s = Scene(p.name, None, functools.partial(p.start_predicate, self), p.enabled)
            s.run = functools.partial(p.run, self, s)
            self.scenes.append(s)

        self.level = level
        self.ms = ms
        self.player = self.level.query(lambda e: e.character == "@").unwrap_or()

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

    def options(self, options: dict[str, Action]):
        assert all(options.values()), "Only actions are allowed; for no action use NoAction"

        yield  # TODO should this be needed? Investigate.
        self.player.ai.memory.options = options
        yield

    def start_cutscene(self):
        self.player.ai.memory.in_cutscene = True
        yield
        self.player.ai.rerender()

    def end_cutscene(self):
        yield
        self.player.ai.memory.in_cutscene = False

    def center_camera(self):
        h, w = self.player.ai.output.game._window.getmaxyx()
        self.player.ai.output.game.virtual_p = sub2(self.player.p, floordiv2((w, h), 2))
        yield

    def scene_by_name(self, name):
        return next(s for s in self.scenes if s.name == name)

    def run_subscene(self, *args, **kwargs):
        def decorator(f):
            s = Scene(f.__name__, None, lambda: True)

            @functools.wraps(f)
            def task(self, scene):
                scene.enabled = False
                yield from f(*args, **kwargs)
                self.scenes.remove(scene)

            s.run = functools.partial(task, self, s)
            self.scenes.append(s)

        return decorator


@dataclass(eq=False)
class Scene:
    name: str
    run: Callable[[], None]
    start_predicate: Callable[[], bool]
    enabled: bool = True

PreScene = namedtuple("PreScene", "name, run, start_predicate, enabled")

def scene(start_predicate: Callable[[RailsBase], bool]):
    return lambda f: PreScene(f.__name__, f, start_predicate, True)
