import curses
import logging
import time
from typing import TYPE_CHECKING

from src.engine.acting.actions.no_action import NoAction
from src.engine.input.hotkeys import generate_hotkeys
from src.systems.ai import Perception

if TYPE_CHECKING:
    from src.entities.ais.io import Memory


class Input:
    def __init__(self, stdscr, debug_track, debug_mode, io):
        stdscr.nodelay(1)

        self.main = stdscr
        self.io = io

        if debug_track:
            self.debug_track = iter(debug_track)
            logging.info(f"Debug track: '{debug_track}'")
        else:
            self.debug_track = None

        self.hotkeys = generate_hotkeys(debug_mode)

        logging.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")

    def read_key(self):
        if self.debug_track is not None:
            hotkey = ord(next(self.debug_track))
        else:
            while (hotkey := self.main.getch()) == -1: pass
        return hotkey

    def wait_for_input(self, subject, perception: Perception, memory: "Memory"):
        if memory.in_cutscene:
            if memory.options:
                mode = "options"
            elif self.io.output.notification.visible:
                mode = "notification"
            elif memory.current_sound is not None:
                mode = "dialog_line"
            else:
                if not memory.is_skipping: time.sleep(0.2)  # TODO flexible
                return NoAction()
        else:
            mode = "game"

        if memory.is_skipping:
            if mode == "options" and len(memory.options) == 1:
                memory.selected_option_i = 0
                return memory.select_option()

            if mode == "dialog_line":
                return NoAction()

        while (
            (key := self.read_key()) not in self.hotkeys[mode]
            or (action := self.hotkeys[mode][key](self.io, subject, perception, memory)) is None
        ):
            self.io.rerender()

        return action
