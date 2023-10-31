import curses
import logging

from src.engine.output.colors import ColorPair
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.game import Game
from src.engine.output.windows.notification import Notification
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel


class Output:
    def __init__(self, io, stdscr, is_render_enabled):
        ColorPair.initialize()
        curses.curs_set(0)

        panel_w = 35
        self.io = io
        self.is_render_enabled = is_render_enabled
        self.stdscr = stdscr
        self.game = Game(io, panel_w)
        self.panel = Panel(io, panel_w)
        self.dialogue_line = DialogueLine(io)
        self.option_picker = OptionPicker(io)
        self.notification = Notification(io)

        self.execution_order = [self.game, self.panel, self.dialogue_line, self.option_picker, self.notification]

    def render(self, subject, perception):
        self.stdscr.refresh()

        if not self.is_render_enabled: return

        for window in self.execution_order:
            try:
                window.render(subject, perception)
            except Exception as ex:
                logging.error(f"Exception when rendering {window}", exc_info=ex)
                if self.io.debug_mode: raise ex
