from dataclasses import dataclass, field
from typing import Any, TypeAlias, Iterator
from xml.dom.minidom import Entity

from ecs import MetasystemFacade

from src.engine.acting.action import Action
from src.lib.vector import sub2, floordiv2
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.library.ais.dummy_ai import DummyAi
from src.library.ais.io import Notification
from src.library.physical.player import Player
from src.library.special.genesis import Genesis
from src.library.special.level import Level


Script: TypeAlias = Iterator[dict[Entity, Action | None] | None]


@dataclass
class RailsApi:
    level: Level
    ms: MetasystemFacade
    genesis: Genesis

    _ai_storage: dict[Entity, Any] = field(default_factory=dict)
    _ai_locks: dict[Entity, list[object]] = field(default_factory=dict)

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
        raise NotImplementedError
        # def decorator(f):
        #     s = Scene(f.__name__, None, lambda: True)
        #
        #     @functools.wraps(f)
        #     def task(self, scene):  # TODO NEXT redo
        #         scene.enabled = False
        #         yield from f(*args, **kwargs)
        #         self.scenes.remove(scene)
        #
        #     s.run = functools.partial(task, self, s)
        #     self.scenes.append(s)
        #     return f
        #
        # return decorator

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
