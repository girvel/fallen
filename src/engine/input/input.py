import curses
import logging
import time

from src.engine.acting.action import Action
from src.lib.query import Q
from src.library.actions.no_action import NoAction
from src.engine.input.hotkeys import generate_hotkeys
from src.engine.input.key_queue import KeyQueue
from src.engine.input.mode import OPTIONS, NOTIFICATION, DIALOGUE_LINE, CUTSCENE, GAME, GENERAL
from src.engine.ai import Perception


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
        if self.io.memory.current_notification:
            mode = NOTIFICATION
        elif self.io.memory.in_cutscene:
            if self.io.memory.options:
                mode = OPTIONS
            elif self.io.memory.current_sound is not None:
                mode = DIALOGUE_LINE
            else:
                mode = CUTSCENE
        else:
            mode = GAME

        is_skipping_cutscene = (
            ~Q(subject.level.rails.current_cutscene).base.name in self.io.memory.cutscenes_to_skip
        )

        # TODO this is not Input's responsibility but Memory's or a separate module?
        if self.io.memory.is_skipping or is_skipping_cutscene:
            if mode == OPTIONS and len(self.io.memory.options) == 1:
                self.io.memory.selected_option_i = 0
                return self.io.memory.select_option()

            if mode == DIALOGUE_LINE:
                return NoAction()

            if mode == NOTIFICATION and is_skipping_cutscene:
                return NoAction()

        hotkeys = self.hotkeys[GENERAL] | self.hotkeys[mode]
        key = self.key_queue.read_key(hotkeys, mode.accepts_empty_input)
        if (used_hotkey := hotkeys.get(key)) is not None:
            return used_hotkey.function(self.io, subject, perception)
