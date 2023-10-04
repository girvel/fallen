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

    def read_key(self, allow_empty=False):
        if self.debug_track is not None:
            hotkey = ord(next(self.debug_track))
        else:
            while (hotkey := self.main.getch()) == -1 and not allow_empty: pass
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
                if not memory.is_skipping:
                    time.sleep(max(0, .2 - time.time() + self.last_t))
                    self.last_t = time.time()
                return self.hotkeys.global_.get(self.read_key(True), NoAction())
        else:
            mode = "game"

        if memory.is_skipping:
            if mode == "options" and len(memory.options) == 1:
                memory.selected_option_i = 0
                return memory.select_option()

            if mode == "dialog_line":
                return NoAction()

        hotkeys = self.hotkeys.global_ | self.hotkeys[mode]

        while (
            (key := self.read_key()) not in hotkeys
            or (action := hotkeys[key](self.io, subject, perception, memory)) is None
        ):
            self.io.rerender()

        return action
