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

@dataclass
class ColorPair:
    fg: int = curses.COLOR_WHITE
    bg: int = curses.COLOR_BLACK

    @classmethod
    def initialize(cls):
        print('\033[?1003h')  # magical value to enable colors
        for fg_i in range(8):
            for bg_i in range(8):
                if fg_i == 0 and bg_i == 0: continue
                curses.init_pair(fg_i * 8 + bg_i, fg_i, bg_i)

    def to_curses(self):
        return curses.color_pair(self.fg * 8 + self.bg)
