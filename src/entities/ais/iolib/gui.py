from ecs import Entity

from src.entities.ais.iolib.windows.debug_monitor import DebugMonitor
from src.entities.ais.iolib.windows.game import Game
from src.entities.ais.iolib.windows.panel import Panel


class Gui:
    def __init__(self, stdscr, debug_mode):
        panel_w = 35
        self.main = stdscr
        self.game = Game(panel_w)
        self.panel = Panel(panel_w)

        self.execution_order = [self.game, self.panel]

        if not debug_mode: return
        self.debug_monitor = DebugMonitor(10, panel_w)
        # self.console = Console()
        self.execution_order += [self.debug_monitor]

    def resize(self):
        h, w = self.main.getmaxyx()

        for window in self.execution_order:
            window.resize(h, w)

    def render(self, subject, perception, level):
        self.main.refresh()

        for window in self.execution_order:
            window.render(subject, perception, level)
