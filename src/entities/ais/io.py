from dataclasses import dataclass, field
from typing import Optional

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.input.input import Input
from src.engine.naming.name import Name
from src.engine.output.output import Output
from src.entities.ais.dummy_ai import DummyAi
from src.entities.special.sound import Sound
from src.lib.concurrency import wait_for
from src.lib.query import Q
from src.lib.toolkit import random_round


@dataclass
class Quest:
    description: str

@dataclass
class Notification:
    header: str
    content: str

@dataclass
class Memory:
    spacial_memory: SpacialMemory = field(default_factory=SpacialMemory)

    current_sound: Optional[Sound] = None

    options: Optional[dict[str, Optional[Action]]] = None
    selected_option_i: int = 0
    last_selected_option: Optional[str] = None

    in_cutscene: bool = False
    is_skipping: bool = False
    is_vision_disabled: bool = False

    _quests: list[Quest] = field(default_factory=list)
    _notification_queue: list[Notification] = field(default_factory=list)
    current_notification: Notification = None

    def add_quest(self, quest: Quest):
        self._quests.append(quest)
        self._notification_queue.append(Notification("Новая задача", quest.description))

    def complete_quest(self, quest: Quest):
        if quest not in self._quests: return

        self._quests.remove(quest)
        self._notification_queue.append(Notification("Задача завершена", quest.description))

    def get_quests(self):
        return self._quests

    def select_option(self):
        self.last_selected_option, result = list(self.options.items())[self.selected_option_i]
        self.options = None
        self.selected_option_i = 0
        return result

class IO(DynamicEntity):  # TODO redo as composite?
    name = Name("Ввод/Вывод")
    cutscene_aware_flag = None

    def __init__(self, stdscr, debug_track, debug_mode, is_render_enabled, max_fps):
        self.debug_mode = debug_mode

        self.output = Output(self, stdscr, is_render_enabled)
        self.input = Input(self, stdscr, debug_track)

        self.memory = Memory()
        self.dummy = DummyAi()

        self.max_fps = max_fps

    def make_decision(self, subject, perception):
        self.form_memory(subject, perception)

        while True:
            if all([
                self.memory.is_skipping,
                ~Q(self.memory.options).Q_len() in (None, 1),
                self.memory.current_notification is None,
            ]):
                self.render_empty()
            else:
                self.render(subject, perception)

            dummy_action = self.dummy.make_decision(subject, perception)
            player_action = self.input.wait_for_input(subject, perception)

            if action := dummy_action or player_action: return action

    def form_memory(self, subject, perception):
        self.memory.spacial_memory.use(subject, perception)

        self.memory.current_sound = next((
            sound
            for sound in perception.hearing.values()
            if sound is not None
        ), None)

        if not self.memory.in_cutscene:
            self.memory.is_skipping = False

        if len(self.memory._notification_queue) > 0:
            self.memory.current_notification = self.memory._notification_queue.pop(0)
        else:
            self.memory.current_notification = None

    last_render_input = None

    def render(self, subject, perception):
        if self.memory.is_vision_disabled: return self.render_empty()

        self.last_render_input = [subject, perception]
        self.output.render(subject, perception)

    def render_empty(self):
        self.output.stdscr.clear()
        self.output.stdscr.refresh()

    def rerender(self):
        if self.last_render_input is None: return
        return self.render(*self.last_render_input)

    def wait_seconds(self, seconds: float):
        yield from wait_for(random_round(seconds * self.max_fps))
