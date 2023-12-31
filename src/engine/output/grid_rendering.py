import curses
from enum import Enum
from statistics import median

from src.lib.vector.vector import int2


class HorizontalAlignment(Enum):
    left = 0
    center = 1
    right = 2


class VerticalAlignment(Enum):
    top = 1
    bottom = -1


def put_string_on_grid(
    array: list[list[str]], w: int2, p: int2, string: str, attributes: int,
    horizontal_alignment: HorizontalAlignment, vertical_alignment: VerticalAlignment
) -> int2:
    x, y = p
    i = 0

    def _realign():
        if horizontal_alignment == HorizontalAlignment.left or len(string) - i >= w:
            return x
        elif horizontal_alignment == horizontal_alignment.right:
            return w - len(string) + i
        else:
            return (w - len(string) + i) // 2

    x = _realign()

    if y >= len(array):
        for _ in range(y - len(array) + 1):
            array.append([" "] * w)

    while True:
        if i >= len(string): break

        if x >= w:
            y += vertical_alignment.value
            x = 0
            x = _realign()

            array.append([" "] * w)

        array[y][x] = (string[i], attributes)

        i += 1
        x += 1

    return x, y


def render_grid(grid: tuple[list[list[str]], int2], window: curses.window, scroll: int) -> None:
    window_h, window_w = window.getmaxyx()
    array, _ = grid

    scroll = median([0, scroll, len(array) - window_h])

    window.move(0, 0)

    for y, row in enumerate(array[scroll:]):
        if y >= window_h: break

        for x, c in enumerate(row):
            if y == window_h - 1 and x == window_w - 1: break
            # curses can not display last window character

            window.addstr(*c)
