import curses
import logging

from src.engine.output.colors import ColorPair
from src.engine.output.window import Center, Reverse
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.game import Game
from src.engine.output.windows.notification import Notification
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel
from src.lib.vector import flip2, sub2, floordiv2

class Output:
    def __init__(self, io, stdscr, is_render_enabled):
        ColorPair.initialize()
        curses.curs_set(0)

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

        for window, positioning in [
            (self.game, (0, 0)),
            (self.panel, (Reverse(3), 1)),
            (self.dialogue_line, (Center(), Reverse(2))),
            # (self.option_picker, ),
            (self.notification, (Center(), Center())),
        ]:
            try:
                window.render(subject, perception, size, positioning)
            except Exception as ex:
                logging.error(f"Exception when rendering {window}", exc_info=ex)
                if self.io.debug_mode: raise ex
