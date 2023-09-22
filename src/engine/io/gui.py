from src.engine.io.windows.console import Console
from src.engine.io.windows.dialogue_line import DialogueLine
from src.engine.io.windows.monitor import Monitor
from src.engine.io.windows.game import Game
from src.engine.io.windows.panel import Panel


class Gui:
    def __init__(self, stdscr, debug_mode, io):
        panel_w = 35
        self.main = stdscr
        self.game = Game(panel_w)
        self.panel = Panel(panel_w, io)
        self.dialogue_line = DialogueLine()

        self.execution_order = [self.game, self.panel, self.dialogue_line]

        if not debug_mode: return
        self.monitor = Monitor(10, panel_w)
        self.console = Console(panel_w)
        self.execution_order += [self.monitor, self.console]

    def resize(self):
        h, w = self.main.getmaxyx()

        for window in self.execution_order:
            window.resize(h, w)

    def render(self, subject, perception, level, memory):
        self.main.refresh()

        for window in self.execution_order:
            window.render(subject, perception, level, memory)
