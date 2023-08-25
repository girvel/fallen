import curses
from enum import Enum

from ecs import OwnedEntity

import logging

log = logging.getLogger(__name__)

class Colors(Enum):
    Default = 0
    Red = 1
    Green = 2
    WhiteOnBlue = 3
    Yellow = 4
    WhiteOnRed = 5


class Screen(OwnedEntity):
    name = 'screen'
    screen_flag = None

    def __init__(self, stdscr):
        super().__init__(main=stdscr, game=curses.newwin(1, 1, 0, 0), gui=curses.newwin(1, 1, 0, 0), gui_w=35)

        log.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        print('\033[?1003h')

        curses.init_pair(Colors.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(Colors.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnBlue.value, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(Colors.Yellow.value, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnRed.value, curses.COLOR_WHITE, curses.COLOR_RED)
