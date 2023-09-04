from ecs import Entity

from src.entities.ais.iolib.windows.game import Game
from src.entities.ais.iolib.windows.panel import Panel


class Gui:
    def __init__(self, stdscr, debug_mode):
        panel_w = 35
        self.main = stdscr
        self.windows = Entity(
            game=Game(panel_w),
            panel=Panel(panel_w),
        )
        # self.windows.debug_monitor = DebugMonitor(debug_mode)
        # self.windows.console = Console(debug_mode)

    def resize(self):
        h, w = self.main.getmaxyx()

        for _, window in self.windows:
            window.resize(h, w)

    def render(self, subject, perception, level):
        self.main.refresh()

        for _, window in self.windows:
            window.render(subject, perception, level)
