import curses
import logging
import time
from typing import TYPE_CHECKING

from src.engine.acting.action import Action
from src.engine.acting.actions.no_action import NoAction
from src.engine.input.hotkeys import generate_hotkeys
from src.engine.input.key_queue import KeyQueue
from src.systems.ai import Perception

if TYPE_CHECKING:
    from src.entities.ais.io import Memory


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

    def wait_for_input(self, subject, perception: Perception, memory: "Memory") -> Action:
        # TODO should be (self, io, subject, perception)

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

        hotkeys = self.hotkeys.global_ | self.hotkeys[mode]
        key = self.key_queue.read_key(hotkeys, mode == "cutscene")  # TODO remove hardcoded values
        if (f := hotkeys.get(key)) is not None:
            return f(self.io, subject, perception, memory)
