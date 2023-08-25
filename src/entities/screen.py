import curses
from enum import Enum

from ecs import OwnedEntity

class Colors(Enum):
    Default = 0
    Red = 1
    Green = 2

class Screen(OwnedEntity):
    def __init__(self, stdscr):
        super().__init__(name='screen', screen_flag=None, main=stdscr)
        curses.init_pair(Colors.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(Colors.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
