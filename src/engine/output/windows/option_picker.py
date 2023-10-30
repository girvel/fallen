import curses
import logging
import math

from src.engine.output.colors import ColorPair, yellow
from src.engine.output.html_window import HtmlWindow
from src.lib.toolkit import add_multiline_string


class OptionPicker:
    def __init__(self, io):
        self._window = curses.newwin(1, 1, 0, 0)
        self.io = io

    def responsive_resize(self):
        h, w = self.io.output.stdscr.getmaxyx()

        own_w = min(40, w - 1)
        own_h = min(h, 2 + sum(math.ceil(len(o) / (own_w - 2)) for o in self.io.memory.options))

        self._window.resize(own_h, own_w)
        self._window.mvwin((h - own_h) // 2, (w - own_w) // 2)

    def render(self, subject, perception):  # TODO NEXT convert this to HTML
        if self.io.memory.options is None: return

        self.responsive_resize()
        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        cursor_y = 1
        for i, o in enumerate(self.io.memory.options):
            cursor_y = add_multiline_string(
                self._window, cursor_y, 1, 1, 1, h, w, o,
                ColorPair(yellow) if i == self.io.memory.selected_option_i else ColorPair()
            )[0] + 1

        self._window.refresh()
