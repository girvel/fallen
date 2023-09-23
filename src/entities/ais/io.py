import logging
from dataclasses import dataclass, field
from typing import Optional

from ecs import OwnedEntity

from src.engine.acting.action import Action
from src.engine.input.input import Input
from src.engine.output.output import Output
from src.entities.special.sound import Sound


@dataclass
class Memory:
    current_sound: Optional[Sound] = None
    options: Optional[dict[str, Optional[Action]]] = None
    selected_option_i: int = 0
    in_cutscene: bool = False

class IO(OwnedEntity):
    name = 'Input/Output'
    level = None
    cutscene_aware_flag = None

    def __init__(self, stdscr, debug_track, debug_mode):
        self.output = Output(stdscr, debug_mode, self)
        self.input = Input(stdscr, debug_track, debug_mode, self)

        self.memory = Memory()
        self.output.resize(self.memory)

    def connect_to_level(self, level):
        self.level = level

    def make_decision(self, subject, perception):
        self.form_memory(subject, perception)
        self.render(subject, perception)
        return self.input.wait_for_input(subject, perception, self.memory)

    def form_memory(self, subject, perception):
        self.memory.current_sound = next((
            sound
            for sound in perception.hearing.values()
            if sound is not None
        ), None)

    last_render_input = None

    def render(self, subject, perception):
        self.last_render_input = [subject, perception]
        self.output.render(subject, perception, self.level, self.memory)

    def rerender(self):
        assert self.last_render_input is not None, "You can rerender only after you render at least once"
        return self.render(*self.last_render_input)
