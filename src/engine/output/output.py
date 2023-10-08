import curses
import logging

from src.engine.output.colors import ColorPair
from src.engine.output.windows.console import Console
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.monitor import Monitor
from src.engine.output.windows.game import Game
from src.engine.output.windows.notification import Notification
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel


class Output:
    def __init__(self, stdscr, debug_mode, no_render, io):
        ColorPair.initialize()
        curses.curs_set(0)

        panel_w = 35
        self.no_render = no_render
        self.main = stdscr
        self.game = Game(panel_w)
        self.panel = Panel(panel_w, io)
        self.dialogue_line = DialogueLine()
        self.option_picker = OptionPicker()
        self.notification = Notification()

        self.execution_order = [self.game, self.panel, self.dialogue_line, self.option_picker, self.notification]

        if not debug_mode: return
        self.monitor = Monitor(10, panel_w)
        self.console = Console(panel_w)
        self.execution_order += [self.monitor, self.console]

    def resize(self):
        h, w = self.main.getmaxyx()

        for window in self.execution_order:
            try:
                window.resize(h, w)
            except Exception as ex:
                logging.error(f"Exception when resizing {window}", exc_info=ex)

    def render(self, subject, perception, memory):
        self.main.refresh()

        if self.no_render: return

        for window in self.execution_order:
            try:
                window.render(subject, perception, memory)
            except Exception as ex:
                logging.error(f"Exception when rendering {window}", exc_info=ex)
