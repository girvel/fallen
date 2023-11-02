import functools
import logging
from dataclasses import dataclass
from typing import Callable

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.naming.name import Name
from src.entities.physical.player import Player
from src.entities.special.level import Level
from src.lib.vector import floordiv2, sub2


class RailsBase(DynamicEntity):
    name = Name("Рельсы")
    rails_flag = None

    def __init__(self, level, ms, genesis, *args, **kwargs):
        self.scenes = []
        self.current_scenes = []

        for s in vars(type(self)).values():
            if not isinstance(s, Scene): continue
            s.run = functools.partial(s.run, self, s)
            s.start_predicate = functools.partial(s.start_predicate, self)
            self.scenes.append(s)

        self.level = level
        self.ms = ms
        self.genesis = genesis

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

        self.__post_init__(*args, **kwargs)

    def __post_init__(self, *args, **kwargs):
        ...

    @functools.cache
    def get_player(self):
        return next(self.level.find(Player), None)

    def options(self, options: dict[str, Action]):
        assert all(options.values()), "Only actions are allowed; for no action use NoAction"

        yield  # TODO should this be needed? Investigate.
        self.get_player().ai.memory.options = options
        yield

    def start_cutscene(self):
        self.get_player().ai.memory.in_cutscene = True
        yield

    def end_cutscene(self):  # TODO next type annotations
        yield
        self.get_player().ai.memory.in_cutscene = False

    def center_camera(self):
        player = self.get_player()
        h, w = player.ai.output.game._window.getmaxyx()
        player.ai.output.game.virtual_p = sub2(player.p, floordiv2((w, h), 2))
        yield

    def scene_by_name(self, name):
        return next(s for s in self.scenes if s.name == name)

    def run_task(self, *args, **kwargs):
        def decorator(f):
            s = Scene(f.__name__, None, lambda: True)

            @functools.wraps(f)
            def task(self, scene):
                scene.enabled = False
                yield from f(*args, **kwargs)
                self.scenes.remove(scene)

            s.run = functools.partial(task, self, s)
            self.scenes.append(s)
            return f

        return decorator

    def plane_shift(self, level, p):
        yield
        self.get_player().ai.memory.is_vision_disabled = True
        Level.change(self.get_player(), level, p)
        yield from self.center_camera()
        self.get_player().ai.memory.is_vision_disabled = False

    def create_entity(self, entity):
        self.genesis.entities_to_create.add(entity)
        yield
        if hasattr(entity, "after_load"): entity.after_load(entity.level)


@dataclass(eq=False)
class Scene:
    name: str
    run: Callable[[...], None]
    start_predicate: Callable[[...], bool]
    enabled: bool = True

    @classmethod
    def new(self, start_predicate: Callable[[RailsBase], bool] = lambda _: True, *, enabled=True):
        return lambda f: Scene(f.__name__, f, start_predicate, enabled)
