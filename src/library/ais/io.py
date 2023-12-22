from dataclasses import dataclass, field
from typing import Optional

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.ai import Perception
from src.engine.input.input import Input
from src.engine.language.name import Name
from src.engine.output.output import Output
from src.lib.concurrency import wait_for
from src.lib.query import Q
from src.lib.toolkit import random_round
from src.lib.vector.vector import d2
from src.library.ai_modules.spacial_memory import CharacterMemory
from src.library.ais.dummy_ai import DummyAi
from src.library.special.sound import Sound


@dataclass
class Quest:
    description: str

@dataclass
class Notification:
    header: str
    content: str

@dataclass
class Memory:
    spacial_memory: CharacterMemory = field(default_factory=CharacterMemory)

    current_sound: Optional[Sound] = None
    chat: list[Sound] = field(default_factory=list)

    options: dict[str, Optional[Action]] | None = None
    selected_option_i: int = 0
    last_selected_option: Optional[str] = None

    in_cutscene: bool = False
    is_skipping: bool = False
    cutscenes_to_skip: list[str] = field(default_factory=list)
    is_vision_disabled: bool = False

    _quests: list[Quest] = field(default_factory=list)
    notification_queue: list[Notification] = field(default_factory=list)
    current_notification: Notification = None

    inspect_target: Entity | None = None

    def add_quest(self, quest: Quest):
        self._quests.append(quest)
        self.notification_queue.append(Notification("Новая задача", quest.description))

    def complete_quest(self, quest: Quest):
        if quest not in self._quests: return

        self._quests.remove(quest)
        self.notification_queue.append(Notification("Задача завершена", quest.description))

    def get_quests(self):
        return self._quests

    def select_option(self):
        self.last_selected_option, result = list(self.options.items())[self.selected_option_i]
        self.options = None
        self.selected_option_i = 0
        return result

class IO(Entity):  # TODO redo as composite AI?
    name = Name("Ввод/Вывод")
    cutscene_aware_flag = None

    tps = 10

    def __init__(self, stdscr, debug_track, debug_mode, is_render_enabled, is_fps_fixed, skipped_cutscenes):
        self.debug_mode = debug_mode

        self.output = Output(self, stdscr, is_render_enabled)
        self.input = Input(self, stdscr, debug_track)

        self.memory = Memory()
        self.memory.cutscenes_to_skip = skipped_cutscenes
        self.dummy = DummyAi()

        self.is_fps_fixed = is_fps_fixed

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

    def form_memory(self, subject, perception: Perception):
        self.memory.spacial_memory.use(subject, perception)

        self.memory.current_sound = None
        current_d_to_sound = float('inf')

        for p, sound in perception.hearing.items():
            if sound is None: continue
            if current_d_to_sound > (next_d_to_sound := d2(subject.p, p)):
                current_d_to_sound = next_d_to_sound
                self.memory.current_sound = sound

            if sound.is_internal: continue
            self.memory.chat.append(sound)

        if not self.memory.in_cutscene:
            self.memory.is_skipping = False

        if len(self.memory.notification_queue) > 0:
            self.memory.current_notification = self.memory.notification_queue.pop(0)
        else:
            self.memory.current_notification = None

        self.memory.inspect_target = None

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
        yield from wait_for(random_round(seconds * self.tps))
