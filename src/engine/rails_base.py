import functools
import logging
from collections import defaultdict
from dataclasses import dataclass
from typing import Callable, Iterator, TypeAlias, Any

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.engine.language.name import Name
from src.library.ais.dummy_ai import DummyAi
from src.library.ais.io import Notification
from src.library.physical.player import Player
from src.library.special.level import Level
from src.lib.vector import floordiv2, sub2


Script: TypeAlias = Iterator[dict[DynamicEntity, Action | None] | None]

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

        self._ai_storage: dict[DynamicEntity, Any] = {}
        self._ai_locks: dict[DynamicEntity, list[object]] = {}

        logging.info(f"Initialized rails with scenes {[s.name for s in self.scenes]}")

        self.__post_init__(*args, **kwargs)

    def __post_init__(self, *args, **kwargs):
        ...

    @functools.cache
    def get_player(self) -> Player:
        return next(self.level.find(Player), None)

    def options(self, options: dict[str, Action]) -> Script:
        assert all(options.values()), "Only actions are allowed; for no action use NoAction"

        yield  # TODO should this be needed? Investigate.
        self.get_player().ai.memory.options = options
        yield

    def start_cutscene(self) -> Script:
        self.get_player().ai.memory.in_cutscene = True
        yield

    def end_cutscene(self) -> Script:
        yield
        self.get_player().ai.memory.in_cutscene = False

    def center_camera(self) -> Script:
        player = self.get_player()
        h, w = player.ai.output.game.curses_window.getmaxyx()
        player.ai.output.game.virtual_p = sub2(player.p, floordiv2((w, h), 2))
        yield

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

    def plane_shift(self, level, p) -> Script:
        yield  # to display the last railed action before the shift
        Level.change(self.get_player(), level, p)

    def create_entity(self, entity) -> Script:
        self.genesis.entities_to_create.add(entity)
        yield
        if hasattr(entity, "after_load"): entity.after_load(entity.level)

    def lock_complex_ai(self, entity) -> object:
        if entity not in self._ai_storage:
            self._ai_storage[entity] = entity.ai
            self._ai_locks[entity] = []

            entity.ai = DummyAi()
            entity.ai.composite[SpacialMemory].knows(self.level)

        entity.ai.clear()

        lock = object()
        self._ai_locks[entity].append(lock)
        return lock

    def unlock_complex_ai(self, entity, lock) -> None:
        self._ai_locks[entity].remove(lock)

        if len(self._ai_locks[entity]) == 0:
            entity.ai = self._ai_storage[entity]
            del self._ai_storage[entity]
            del self._ai_locks[entity]

    def notify(self, notification: Notification):
        self.get_player().ai.memory.notification_queue.append(notification)
        yield



@dataclass(eq=False)
class Scene:
    name: str
    run: "Callable[[Scene], Script]"
    start_predicate: Callable[[RailsBase], bool]
    enabled: bool = True

    @classmethod
    def new(self, start_predicate: Callable[[RailsBase], bool] = lambda _: True, *, enabled=True):
        def _decorator(f: Callable[[Scene], Script]) -> "Scene":
            return Scene(f.__name__, f, start_predicate, enabled)

        return _decorator
