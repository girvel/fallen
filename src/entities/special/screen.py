import curses
from enum import Enum
from statistics import median

from ecs import OwnedEntity

from src.lib.vector import Vector, zero

import logging

log = logging.getLogger(__name__)


def _get_color_pair(entity):
    if entity is None:
        return Colors.Default

    if getattr(entity, "receives_damage", None):
        return Colors.Red

    return getattr(entity, "color", Colors.Default)

def get_color_pair(entity):
    return curses.color_pair(_get_color_pair(entity).value)

class Colors(Enum):
    Default = 0
    Red = 1
    Green = 2
    WhiteOnBlue = 3
    Yellow = 4
    WhiteOnRed = 5

    def format(self):
        return curses.color_pair(self.value)


class Screen(OwnedEntity):
    name = 'screen'
    screen_flag = None
    virtual_p = Vector(0, 0)
    following_offset = Vector(0, 0)  # modified on resize

    gui_w = 35

    def __init__(self, stdscr):
        self.main = stdscr
        self.game = curses.newwin(1, 1, 0, 0)
        self.gui = curses.newwin(1, 1, 0, 0)
        self.level_size = None

        log.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        print('\033[?1003h')

        curses.init_pair(Colors.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(Colors.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnBlue.value, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(Colors.Yellow.value, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnRed.value, curses.COLOR_WHITE, curses.COLOR_RED)

    def refresh_level_size(self, level_size):
        self.level_size = level_size

    def move_camera(self, subject):
        h, w = self.game.getmaxyx()

        self.virtual_p = Vector(
            median((
                0,
                subject.p.x - w + self.following_offset.x,
                self.virtual_p.x,
                subject.p.x - self.following_offset.x,
                self.level_size.x - w,
            )),
            median((
                0,
                subject.p.y - h + self.following_offset.y,
                self.virtual_p.y,
                subject.p.y - self.following_offset.y,
                self.level_size.y - h,
            ))
        )

    def display_perception(self, subject, perception):
        self.game.clear()
        h, w = self.game.getmaxyx()
        screen_size = Vector(w - 1, h)

        for p, entity in perception.vision.items():
            p_on_screen = p - self.virtual_p
            if not (zero <= p_on_screen < screen_size): continue

            self.game.addch(
                p_on_screen.y, p_on_screen.x,
                entity and entity.character or ".",
                get_color_pair(entity) | (
                    entity and entity == subject.inspects and curses.A_REVERSE or 0
                )
            )

        self.game.refresh()
