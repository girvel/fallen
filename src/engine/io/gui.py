from src.engine.io.windows.console import Console
from src.engine.io.windows.monitor import Monitor
from src.engine.io.windows.game import Game
from src.engine.io.windows.panel import Panel


class Gui:
    def __init__(self, stdscr, debug_mode, io):
        panel_w = 35
        self.main = stdscr
        self.game = Game(panel_w)
        self.panel = Panel(panel_w, io)

        self.execution_order = [self.game, self.panel]

        if not debug_mode: return
        self.monitor = Monitor(10, panel_w)
        self.console = Console(panel_w)
        self.execution_order += [self.monitor, self.console]

    def resize(self):
        h, w = self.main.getmaxyx()

        for window in self.execution_order:
            window.resize(h, w)

    def render(self, subject, perception, level):
        self.main.refresh()

        for window in self.execution_order:
            window.render(subject, perception, level)
