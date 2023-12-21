from dataclasses import dataclass
from typing import Any, TypeAlias, Iterator, ClassVar
from xml.dom.minidom import Entity

from src.engine.acting.action import Action
from src.engine.ai import Senses
from src.lib.query import Q
from src.lib.vector.vector import sub2, floordiv2
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.library.ais.dummy_ai import DummyAi
from src.library.ais.io import Notification
from src.library.physical.player import Player
from src.components import Genesis
from src.library.special.level import Level

Script: TypeAlias = Iterator[dict[Entity, Action | None] | None]


@dataclass
class RailsApi:
    level: Level
    genesis: Genesis

    _player: Player | None = None

    _ai_storage: ClassVar[dict[Entity, Any]] = {}
    _ai_locks: ClassVar[dict[Entity, list[object]]] = {}

    _death_storage: ClassVar[dict[Entity, Any]] = {}
    _death_locks: ClassVar[dict[Entity, list[object]]] = {}

    def get_player(self) -> Player:
        if self._player is None:
            self._player = next(self.level.find(Player), None)

        return self._player

    def options(self, options: dict[str, Action]) -> Script:
        assert all(options.values()), "Only actions are allowed; for no action use NoAction"

        yield  # TODO should this be needed? Investigate.
        self.get_player().ai.memory.options = options
        yield
        return self.get_player().ai.memory.last_selected_option

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

    def plane_shift(self, level, p) -> Script:
        yield  # to display the last railed action before the shift
        Level.move(self.get_player(), p, level=level)  # TODO is it needed? maybe use yield {entity: Teleport}?

    def create_entity(self, entity) -> Script:  # TODO not needed, replace with genesis.push
        self.genesis.push(entity)
        yield

    def lock_complex_ai(self, entity, lock) -> Any:
        if entity not in self._ai_storage:
            self._ai_storage[entity] = entity.ai, entity.senses
            self._ai_locks[entity] = []

            entity.ai = DummyAi()
            entity.ai.composite[SpacialMemory].knows(self.level)
            entity.senses = Senses(entity.senses.vision, entity.senses.hearing, entity.senses.smell, attention_k=1)

        assert lock not in self._ai_locks[entity]

        entity.ai.clear()  # TODO LONG it interrupts previous scene. Is it appropriate?

        self._ai_locks[entity].append(lock)
        return lock

    def unlock_complex_ai(self, entity, lock):
        self._ai_locks[entity].remove(lock)

        if len(self._ai_locks[entity]) == 0:
            entity.ai, entity.senses = self._ai_storage[entity]
            del self._ai_storage[entity]
            del self._ai_locks[entity]

    def lock_dying(self, entity, lock) -> Any:
        if entity not in self._death_storage:
            self._death_storage[entity] = ~Q(entity).on_destruction or (lambda *_, **__: None)
            self._death_locks[entity] = []

            entity.on_destruction = (lambda *_, **__: True)

        assert lock not in self._death_locks[entity]

        self._death_locks[entity].append(lock)
        return lock

    def unlock_dying(self, entity, lock):
        self._death_locks[entity].remove(lock)

        if len(self._death_locks[entity]) == 0:
            entity.on_destruction = self._death_storage[entity]
            del self._death_storage[entity]
            del self._death_locks[entity]

    def notify(self, notification: Notification):
        self.get_player().ai.memory.notification_queue.append(notification)
        yield


@dataclass(eq=False)
class Lock:
    info: Any = None

    def __eq__(self, other):
        return self is other
