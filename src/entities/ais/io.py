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
    in_cutscene: bool = False

class IO(OwnedEntity):
    name = 'Input/Output'
    level = None
    cutscene_aware_flag = None

    def __init__(self, stdscr, debug_track, debug_mode):
        self.output = Output(stdscr, debug_mode, self)
        self.input = Input(stdscr, debug_track, debug_mode, self)

        self.output.resize()
        self.memory = Memory()

    def connect_to_level(self, level):
        self.level = level

    def make_decision(self, subject, perception):
        self.form_memory(subject, perception)
        self.render(subject, perception)
        return self.input.wait_for_input(subject, perception)

    def form_memory(self, subject, perception):
        self.memory.current_sound = next((
            sound
            for sound in perception.hearing.values()
            if sound is not None
        ), None)

    def render(self, subject, perception):
        self.output.render(subject, perception, self.level, self.memory)
