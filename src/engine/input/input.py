import curses
import logging
import time

from src.engine.acting.action import Action
from src.engine.acting.actions.no_action import NoAction
from src.engine.input.hotkeys import generate_hotkeys
from src.engine.input.key_queue import KeyQueue
from src.systems.ai import Perception


class Input:
    def __init__(self, io, stdscr, debug_track):
        stdscr.nodelay(1)
        logging.info(f"Initialized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        curses.raw()

        self.io = io
        self.hotkeys = generate_hotkeys(io.debug_mode)
        self.last_t = time.time()
        self.key_queue = KeyQueue(stdscr, debug_track and iter(debug_track))

        if debug_track:
            logging.info(f"Debug track: '{debug_track}'")

    def wait_for_input(self, subject, perception: Perception) -> Action:
        if self.io.memory.in_cutscene:
            if self.io.memory.options:
                mode = "options"
            elif self.io.memory.current_notification:
                mode = "notification"
            elif self.io.memory.current_sound is not None:
                mode = "dialog_line"
            else:
                mode = "cutscene"
        else:
            mode = "game"

        if self.io.memory.is_skipping:  # TODO this is not Input's responsibility but Memory's or a separate module
            if mode == "options" and len(self.io.memory.options) == 1:
                self.io.memory.selected_option_i = 0
                return self.io.memory.select_option()

            if mode == "dialog_line":
                return NoAction()

        hotkeys = self.hotkeys.global_ | self.hotkeys[mode]
        key = self.key_queue.read_key(hotkeys, mode == "cutscene")  # TODO remove hardcoded values
        if (used_hotkey := hotkeys.get(key)) is not None:
            return used_hotkey.function(self.io, subject, perception)
