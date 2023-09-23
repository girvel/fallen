import curses
import logging

from src.engine.output.colors import Colors
from src.lib.query import Query
from src.lib.toolkit import cut_by_length, add_multiline_string


class DialogueLine:
    def __init__(self):
        self._window = curses.newwin(1, 1, 0, 0)

    def resize(self, h, w, memory):
        this_w = min(80, w - 20)
        this_h = 7

        self._window.resize(this_h, this_w)
        self._window.mvwin(h - this_h - 2, (w - this_w) // 2)

    def render(self, subject, perception, level, memory):
        if memory.current_sound is None: return

        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        if not memory.current_sound.is_internal:
            self._window.addstr(
                1, 6,
                ~Query(perception.vision.physical.get(memory.current_sound.p)).name or "???",
                Colors.Yellow.format()
            )

        add_multiline_string(self._window, 2, 2, h, w, memory.current_sound.content)

        self._window.refresh()