import functools
import logging
from collections import namedtuple
from dataclasses import dataclass
from typing import Callable, Any

from ecs import OwnedEntity

from src.lib.vector import floordiv2, sub2


class RailsBase(OwnedEntity):
    name = "Rails"
    rails_flag = None

    def __init__(self, level):
        self.player = level.player
        self.scenes = {
            p.name: Scene(functools.partial(p.run, self), functools.partial(p.start_predicate, self), p.enabled)
            for p in vars(type(self)).values()
            if isinstance(p, PreScene)
        }

        logging.info(f"Initialized rails with scenes {list(self.scenes)}")

    def options(self, options):
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


@dataclass
class Scene:
    run: Callable[[], None]
    start_predicate: Callable[[], bool]
    enabled: True

PreScene = namedtuple("PreScene", "name, run, start_predicate, enabled")

def scene(start_predicate: Callable[[RailsBase], bool]):
    return lambda f: PreScene(f.__name__, f, start_predicate, True)
