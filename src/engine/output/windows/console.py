import curses

from src.lib.toolkit import cut_by_length


class Console:
    def __init__(self, w):
        self._window = curses.newwin(1, 1, 0, 0)
        self.visible = False
        self.buffer = ""
        self.w = w

    def resize(self, h, w):
        self._window.resize(h - 1, self.w)
        self._window.mvwin(0, w - self.w)

    def render(self, subject, perception, memory):
        if not self.visible: return

        self._window.clear()
        self._window.border()

        for i, string in enumerate(
            sum(map(lambda s: cut_by_length(s, self.w - 2), self.buffer.split("\n")), start=[])
        ):
            self._window.addstr(1 + i, 1, string)

        self._window.refresh()