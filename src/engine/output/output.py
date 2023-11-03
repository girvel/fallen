import curses
import logging

from src.engine.output.colors import ColorPair
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.game import Game
from src.engine.output.windows.notification import Notification
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel
from src.lib.vector import flip2, sub2, floordiv2

SIGNAL_CENTERED = object()

class Output:
    def __init__(self, io, stdscr, is_render_enabled):
        ColorPair.initialize()
        curses.curs_set(0)

        self.panel_w = 35
        self.io = io
        self.is_render_enabled = is_render_enabled
        self.stdscr = stdscr

        self.game = Game(io)
        self.panel = Panel(io)
        self.dialogue_line = DialogueLine(io)
        self.option_picker = OptionPicker(io)
        self.notification = Notification(io)

    def render(self, subject, perception):
        self.stdscr.refresh()

        if not self.is_render_enabled: return
        size = flip2(self.stdscr.getmaxyx())

        for window, size, positioning in [
            (self.game, sub2(size, (0, 1) if self.io.memory.in_cutscene else (self.panel_w, 1)), (0, 0)),
            # (self.panel, ),
            # (self.dialogue_line, ),
            # (self.option_picker, ),
            (self.notification, size, SIGNAL_CENTERED),
        ]:
            try:
                # TODO NEXT extract Window's function
                if not window.update_visibility(subject, perception): continue

                window_size = window.responsive_size(subject, perception, size)
                window.curses_window.resize(*flip2(window_size))

                match positioning:
                    case w, h:
                        window.curses_window.mvwin(h, w)
                    case CENTERED:
                        window.curses_window.mvwin(*flip2(floordiv2(sub2(size, window_size), 2)))

                window.render(subject, perception)

            except Exception as ex:
                logging.error(f"Exception when rendering {window}", exc_info=ex)
                if self.io.debug_mode: raise ex
