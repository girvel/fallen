import curses
import logging
import time
from collections import defaultdict
from typing import TYPE_CHECKING

from src.engine.acting.actions.no_action import NoAction
from src.engine.input.hotkeys import generate_hotkeys
from src.systems.ai import Perception

if TYPE_CHECKING:
    from src.entities.ais.io import Memory


class Input:
    def __init__(self, stdscr, debug_track, debug_mode, io):
        stdscr.nodelay(1)
        logging.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")

        self.main = stdscr
        self.io = io

        if debug_track:
            self.debug_track = iter(debug_track)
            logging.info(f"Debug track: '{debug_track}'")
        else:
            self.debug_track = None

        self.hotkeys = generate_hotkeys(debug_mode)
        self.last_t = time.time()
        self._key_queue = []

    def read_key(self, mode=None, allow_empty=False):
        hotkeys = self.hotkeys.global_ | self.hotkeys[mode]

        if len(self._key_queue) > 0 and self._key_queue[0] in hotkeys:
            hotkey, *self._key_queue = self._key_queue
            return hotkey

        if self.debug_track is not None:
            hotkey = ord(next(self.debug_track))
        else:
            while (hotkey := self.main.getch()) == -1 and mode != "cutscene": pass  # TODO remove hardcoded values

        if hotkey not in (-1, curses.KEY_MOUSE):
            self._key_queue.clear()

        if mode is None or hotkey in hotkeys:
            return hotkey

        self._key_queue.append(hotkey)

    def wait_for_input(self, subject, perception: Perception, memory: "Memory"):
        if memory.in_cutscene:
            if memory.options:
                mode = "options"
            elif self.io.output.notification.visible:
                mode = "notification"
            elif memory.current_sound is not None:
                mode = "dialog_line"
            else:
                mode = "cutscene"
        else:
            mode = "game"

        if memory.is_skipping:
            if mode == "options" and len(memory.options) == 1:
                memory.selected_option_i = 0
                return memory.select_option()

            if mode == "dialog_line":
                return NoAction()

        key = self.read_key(mode)
        if (f := (self.hotkeys.global_ | self.hotkeys[mode]).get(key)) is not None:
            return f(self.io, subject, perception, memory)
