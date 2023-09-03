import curses
from enum import Enum


class Colors(Enum):
    Default = 0
    Red = 1
    Green = 2
    WhiteOnBlue = 3
    Yellow = 4
    WhiteOnRed = 5
    Magenta = 6

    def format(self):
        return curses.color_pair(self.value)

    @classmethod
    def initialize(cls):
        curses.init_pair(cls.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(cls.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(cls.WhiteOnBlue.value, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(cls.Yellow.value, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(cls.WhiteOnRed.value, curses.COLOR_WHITE, curses.COLOR_RED)
        curses.init_pair(cls.Magenta.value, curses.COLOR_MAGENTA, curses.COLOR_BLACK)


def _get_color_pair(entity):
    if entity is None:
        return Colors.Default

    if getattr(entity, "receives_damage", None):
        return Colors.Red

    return getattr(entity, "color", Colors.Default)


def get_color_pair(entity):
    return curses.color_pair(_get_color_pair(entity).value)
