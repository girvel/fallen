import curses
import logging

from src.engine.io.colors import Colors
from src.lib.query import Query
from src.lib.toolkit import cut_by_length


class DialogueLine:
    def __init__(self):
        self._window = curses.newwin(1, 1, 0, 0)

    def resize(self, h, w):
        this_w = min(80, w - 20)
        this_h = 7

        self._window.resize(this_h, this_w)
        self._window.mvwin(h - this_h - 2, (w - this_w) // 2)

    def render(self, subject, perception, level, memory):
        if memory.current_sound is None: return

        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        self._window.addstr(1, 6, ~Query(perception.vision.physical.get(memory.current_sound.p)).name or "???", Colors.Yellow.format())

        # TODO add_multiline_string(window, y, padding_w, line)
        for i, line in enumerate(cut_by_length(memory.current_sound.content, w - 4)):
            if 2 + i >= w:
                logging.warning(f"The line is too long to display: '{memory.current_sound.content}'")
                return

            self._window.addstr(2 + i, 2, line)

        self._window.refresh()