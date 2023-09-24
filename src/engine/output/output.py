from src.engine.output.colors import Colors
from src.engine.output.windows.console import Console
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.monitor import Monitor
from src.engine.output.windows.game import Game
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel


class Output:
    def __init__(self, stdscr, debug_mode, io):
        Colors.initialize()

        panel_w = 35
        self.main = stdscr
        self.game = Game(panel_w)
        self.panel = Panel(panel_w, io)
        self.dialogue_line = DialogueLine()
        self.option_picker = OptionPicker()

        self.execution_order = [self.game, self.panel, self.dialogue_line, self.option_picker]

        if not debug_mode: return
        self.monitor = Monitor(10, panel_w)
        self.console = Console(panel_w)
        self.execution_order += [self.monitor, self.console]

    def resize(self, memory):
        h, w = self.main.getmaxyx()

        for window in self.execution_order:
            window.resize(h, w, memory)

    def render(self, subject, perception, level, memory):
        self.main.refresh()

        for window in self.execution_order:
            window.render(subject, perception, level, memory)
