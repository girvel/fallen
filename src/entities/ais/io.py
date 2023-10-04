import logging
from dataclasses import dataclass, field
from typing import Optional

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.input.input import Input
from src.engine.output.output import Output
from src.entities.special.sound import Sound


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

    _quests: list[Quest] = field(default_factory=list)
    _notifications: list[Notification] = field(default_factory=list)

    def add_quest(self, quest: Quest):
        self._quests.append(quest)
        self._notifications.append(Notification("Новая задача", quest.description))

    def complete_quest(self, quest: Quest):
        if quest in self._quests: self._quests.remove(quest)

    def pop_notification(self):
        return self._notifications.pop() if len(self._notifications) > 0 else None

    def select_option(self):
        self.last_selected_option, result = list(self.options.items())[self.selected_option_i]
        self.options = None
        self.selected_option_i = 0
        return result

class IO(DynamicEntity):
    name = 'Input/Output'
    cutscene_aware_flag = None

    def __init__(self, stdscr, debug_track, debug_mode, no_render):
        self.output = Output(stdscr, debug_mode, no_render, self)
        self.input = Input(stdscr, debug_track, debug_mode, self)

        self.memory = Memory()
        self.output.resize()

    def make_decision(self, subject, perception):
        self.form_memory(subject, perception)

        if not self.memory.is_skipping or (self.memory.options and len(self.memory.options) != 1):
            self.render(subject, perception)
        else:
            self.render_empty()

        return self.input.wait_for_input(subject, perception, self.memory)

    def form_memory(self, subject, perception):
        self.memory.spacial_memory.push(subject, perception)

        self.memory.current_sound = next((
            sound
            for sound in perception.hearing.values()
            if sound is not None
        ), None)

        if not self.memory.in_cutscene:
            self.memory.is_skipping = False

    last_render_input = None

    def render(self, subject, perception):
        self.last_render_input = [subject, perception]
        self.output.render(subject, perception, self.memory)

    def render_empty(self):
        self.output.main.clear()
        self.output.main.refresh()

    def rerender(self):
        if self.last_render_input is None: return
        return self.render(*self.last_render_input)
