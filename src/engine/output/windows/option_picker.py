import curses
import logging
import math

from src.engine.output.colors import Colors
from src.lib.toolkit import add_multiline_string


class OptionPicker:
    def __init__(self):
        self._window = curses.newwin(1, 1, 0, 0)
        self.last_parent_h = None
        self.last_parent_w = None

    def resize(self, h, w, memory):
        self.last_parent_h = h
        self.last_parent_w = w

        if memory.options is None: return

        own_w = min(40, w - 1)
        own_h = min(h, 2 + sum(math.ceil(len(o) / (own_w - 2)) for o in memory.options))

        self._window.resize(own_h, own_w)
        self._window.mvwin((h - own_h) // 2, (w - own_w) // 2)

    def render(self, subject, perception, level, memory):
        if memory.options is None: return

        self.resize(self.last_parent_h, self.last_parent_w, memory)
        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        cursor_y = 1
        for i, o in enumerate(memory.options):
            cursor_y = add_multiline_string(
                self._window, cursor_y, 1, h - 1, w, o,
                Colors.Yellow if i == memory.selected_option_i else Colors.Default
            )

        self._window.refresh()