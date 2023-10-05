import curses

from ecs import Entity

from src.engine.output.colors import ColorPair, yellow


class Monitor:
    def __init__(self, h, w):
        self._window = curses.newwin(1, 1, 0, 0)
        self.values = Entity()
        self.h = h
        self.w = w

    def resize(self, h, w):
        self._window.resize(self.h, self.w)
        self._window.mvwin(0, 0)

    def render(self, subject, perception, memory):
        if len(self.values) == 0: return

        self._window.clear()
        self._window.border()

        for i, (header, f) in enumerate(self.values):
            self._window.addstr(1 + i, 1, f"{header}:")

            try:
                value = f()
            except Exception as ex:
                value = ex

            self._window.addstr(1 + i, 1 + len(header) + 2, repr(value), ColorPair(yellow).to_curses())

            if i >= self.h - 2:
                break

        self._window.refresh()
