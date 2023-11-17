import curses
from enum import Enum

from src.lib.vector import int2


class HorizontalAlignment(Enum):
    left = 0
    center = 1
    right = 2


class VerticalAlignment(Enum):
    top = 1
    bottom = -1


def put_string_on_grid(
    grid: tuple[list[list[str]], int2], p: int2, string: str, attributes: int,
    horizontal_alignment: HorizontalAlignment, vertical_alignment: VerticalAlignment
) -> int2:
    x, y = p
    array, (w, h) = grid
    i = 0

    def _realign():
        if horizontal_alignment == HorizontalAlignment.left or len(string) - i >= w:
            return x
        elif horizontal_alignment == horizontal_alignment.right:
            return w - len(string) + i
        else:
            return (w - len(string) + i) // 2

    x = _realign()

    while True:
        if x >= w:
            y += vertical_alignment.value
            x = _realign()

        if i >= len(string): break

        if 0 <= y < w and 0 <= x < w:
            array[y][x] = (string[i], attributes)

        i += 1
        x += 1

    return x, y


def render_grid(grid: tuple[list[list[str]], int2], window: curses.window) -> None:
    array, (w, h) = grid
    window.move(0, 0)

    for y in range(0, h):
        for x in range(0, w):
            if y == h - 1 and x == w - 1: break

            window.addstr(*array[y][x])
