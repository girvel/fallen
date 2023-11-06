import curses
from dataclasses import dataclass
from enum import Enum


white = curses.COLOR_WHITE
black = curses.COLOR_BLACK
red = curses.COLOR_RED
green = curses.COLOR_GREEN
blue = curses.COLOR_BLUE
yellow = curses.COLOR_YELLOW
cyan = curses.COLOR_CYAN
magenta = curses.COLOR_MAGENTA

_color_scheme = {
    black:   0x1d1f21,
    red:     0xcc6666,
    green:   0x93bd68,
    yellow:  0xf0c674,
    blue:    0x81a2be,
    magenta: 0xb294bb,
    cyan:    0x8abeb7,
    white:   0xc5c8c6,
}

@dataclass
class ColorPair:
    fg: int = white
    bg: int = black

    @classmethod
    def initialize(cls):
        print('\033[?1003h')  # magical value to enable colors

        if curses.can_change_color():
            for color_i in range(8):
                hex = _color_scheme[color_i]
                curses.init_color(color_i,
                    round((hex // 0x010000        ) / 0x100 * 1000),
                    round((hex // 0x000100 % 0x100) / 0x100 * 1000),
                    round((hex             % 0x100) / 0x100 * 1000),
                )

        for fg_i in range(8):
            for bg_i in range(8):
                if fg_i == 0 and bg_i == 0: continue
                curses.init_pair(fg_i * 8 + bg_i, fg_i, bg_i)

    def to_curses(self):
        return curses.color_pair(self.to_code())

    def to_code(self):
        return self.fg * 8 + self.bg

    @classmethod
    def from_code(cls, code):
        return cls(code // 8, code % 8)
