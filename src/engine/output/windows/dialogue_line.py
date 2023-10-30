import curses

from src.engine.output.colors import ColorPair, yellow
from src.lib.query import Q
from src.lib.toolkit import add_multiline_string, soft_capitalize


class DialogueLine:
    def __init__(self, io):
        self._window = curses.newwin(1, 1, 0, 0)
        self.io = io

    def _resize(self):
        h, w = self.io.output.stdscr.getmaxyx()

        this_w = min(80, w - 20)
        this_h = 7

        self._window.resize(this_h, this_w)
        self._window.mvwin(h - this_h - 2, (w - this_w) // 2)

    def render(self, subject, perception):
        if self.io.memory.current_sound is None: return

        self._resize()

        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        if not self.io.memory.current_sound.is_internal:
            self._window.addstr(
                1, 6,
                soft_capitalize(str(~Q(perception.vision.physical.get(self.io.memory.current_sound.p)).name or "???")),
                ColorPair(yellow).to_curses()
            )

        add_multiline_string(self._window, 2, 2, 1, 2, h, w, self.io.memory.current_sound.content)

        self._window.refresh()
