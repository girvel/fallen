import curses
from abc import ABC, abstractmethod
from dataclasses import dataclass

from src.lib.vector.vector import flip2, sub2, int2, add2, median2


@dataclass
class Center: pass

@dataclass
class Reverse:
    value: int

Coordinate = int | Center | Reverse
def positioning_to_position(positioning: tuple[Coordinate, Coordinate], max_size: int2, window_size: int2) -> int2:
    def _convert(i: int, coordinate: Coordinate) -> int:
        match coordinate:
            case Center(): return (max_size[i] - window_size[i]) // 2
            case Reverse(v): return max_size[i] - window_size[i] - v
            case v: return int(v)

    return _convert(0, positioning[0]), _convert(1, positioning[1])


class Window(ABC):
    def __init__(self, parent: curses.window, io):
        self.parent_curses_window = parent
        self.curses_window = curses.newwin(1, 1, 0, 0)
        self.io = io

    def render(self, subject, perception, parent_size, positioning):
        if not self.update_visibility(subject, perception): return

        window_size = self._responsive_size(subject, perception, parent_size)

        self.curses_window.resize(*flip2(window_size))
        self.curses_window.mvwin(*add2(
            self.parent_curses_window.getbegyx(),
            flip2(median2((
                (0, 0),
                positioning_to_position(positioning, parent_size, window_size),
                sub2(parent_size, window_size)
            ))),
        ))

        self._render(subject, perception)

    @abstractmethod
    def _render(self, subject, perception):
        ...

    def _responsive_size(self, subject, perception, max_size):
        return max_size

    def update_visibility(self, subject, perception):
        self.visible = self._calculate_visibility(subject, perception)
        return self.visible

    def _calculate_visibility(self, subject, perception):
        return True
