import curses
import logging

from src.engine.output.colors import ColorPair
from src.engine.output.window import Center, Reverse
from src.engine.output.windows.dialogue_line import DialogueLine
from src.engine.output.windows.game import Game
from src.engine.output.windows.hint import Hint
from src.engine.output.windows.notification import Notification
from src.engine.output.windows.option_picker import OptionPicker
from src.engine.output.windows.panel import Panel
from src.engine.output.windows.stats import Stats
from src.lib.query import Q
from src.lib.vector.vector import flip2, sub2


class Output:
    def __init__(self, io, stdscr, is_render_enabled):
        ColorPair.initialize()
        curses.curs_set(0)

        self.io = io
        self.is_render_enabled = is_render_enabled
        self.stdscr = stdscr

        # TODO maybe TypeDict?
        self.game = Game(self.stdscr, io)
        self.stats = Stats(self.stdscr, io)
        self.panel = Panel(self.stdscr, io)
        self.dialogue_line = DialogueLine(self.stdscr, io)
        self.option_picker = OptionPicker(self.stdscr, io)
        self.notification = Notification(self.stdscr, io)
        self.hint = Hint(self.stdscr, io)

    def render(self, subject, perception):
        self.stdscr.refresh()

        if not self.is_render_enabled: return
        size = flip2(self.stdscr.getmaxyx())

        # TODO maybe move positioning into the window itself?
        def _get_hint_position():
            w, h = self.hint.get_size(subject, perception, size)
            if (p := ~Q(self.io.memory.inspect_target).p) is None: return 0, 0
            return sub2(sub2(p, self.game.virtual_p), (w // 2, h))

        for window, positioning in [
            (self.game, (0, 0)),
            (self.stats, (Reverse(3), 1)),
            (self.panel, (Reverse(3), 11)),
            (self.dialogue_line, (Center(), Reverse(2))),
            (self.option_picker, (Center(), Center())),
            (self.notification, (Center(), Center())),
            (self.hint, _get_hint_position())
        ]:
            try:
                window.render(subject, perception, size, positioning)
            except Exception as ex:
                logging.error(f"Exception when rendering {window}", exc_info=ex)
                if self.io.debug_mode: raise ex
