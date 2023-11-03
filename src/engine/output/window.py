import curses
from abc import ABC, abstractmethod

from src.lib.vector import flip2, floordiv2, sub2

SIGNAL_CENTERED = object()

class Window(ABC):
    def __init__(self, io):
        self.curses_window = curses.newwin(1, 1, 0, 0)
        self.io = io

    def render(self, subject, perception, size, positioning):
        if not self.update_visibility(subject, perception): return

        window_size = self.responsive_size(subject, perception, size)
        self.curses_window.resize(*flip2(window_size))

        match positioning:
            case w, h:
                self.curses_window.mvwin(h, w)
            case CENTERED:
                self.curses_window.mvwin(*flip2(floordiv2(sub2(size, window_size), 2)))

        self._render(subject, perception)

    @abstractmethod
    def _render(self, subject, perception):
        ...

    def responsive_size(self, subject, perception, max_size):
        return max_size

    def update_visibility(self, subject, perception):
        self.visible = self._calculate_visibility(subject, perception)
        return self.visible

    def _calculate_visibility(self, subject, perception):
        return True
