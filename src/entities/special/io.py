import curses
import sys
from enum import Enum
from statistics import median

from ecs import OwnedEntity

from src.lib.vector import Vector, zero, up, down, left, right

import logging

from src.systems.acting.attack import Attack
from src.systems.acting.inspect import Inspect
from src.systems.acting.move import Move

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


class IO(OwnedEntity):
    name = 'Input/Output'

    # input
    virtual_p = Vector(0, 0)
    following_offset = Vector(0, 0)  # modified on resize
    gui_w = 35
    level_size = None

    # output
    mode = Move

    def __init__(self, stdscr):
        self.main = stdscr
        self.game = curses.newwin(1, 1, 0, 0)
        self.gui = curses.newwin(1, 1, 0, 0)

        self.hotkeys = generate_default_hotkeys()

        log.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        print('\033[?1003h')

        curses.init_pair(Colors.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(Colors.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnBlue.value, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(Colors.Yellow.value, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnRed.value, curses.COLOR_WHITE, curses.COLOR_RED)

    def refresh_level_size(self, level_size):
        self.level_size = level_size

    def make_decision(self, subject, perception):
        self.resize_windows()
        self.move_camera(subject)
        self.display_perception(subject, perception)
        self.display_gui(subject)
        return self.wait_for_input(subject, perception.vision)

    def resize_windows(self):
        # TODO as a reaction to event, not on update
        h, w = self.main.getmaxyx()
        self.game.resize(h - 1, w - self.gui_w)
        self.following_offset = Vector(w - self.gui_w, h - 1) // 3
        self.gui.resize(h - 1, self.gui_w)
        self.gui.mvwin(0, w - self.gui_w)

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
                    entity and isinstance(subject.act, Inspect) and subject.act.subject == entity
                        and curses.A_REVERSE
                        or 0
                )
            )

        self.game.refresh()

    def display_gui(self, subject):
        self.gui.clear()
        self.gui.border()

        name_tag = f"\__ {subject.name} __/"

        self.gui.addstr(1, 2, " " * ((self.gui_w - 2 - len(name_tag)) // 2) + name_tag, curses.A_BOLD)
        self.gui.addstr(4, 2, f"Health: ")
        self.gui.addstr(4, 10, str(subject.health.value), Colors.Yellow.format())
        self.gui.addstr(5, 2, f"Armor: ")
        self.gui.addstr(5, 10, subject.health.armor_kind, Colors.Yellow.format())
        self.gui.addstr(6, 2, f"Damage: ")
        self.gui.addstr(6, 10, f"{subject.weapon.power} {subject.weapon.damage_kind}", Colors.Yellow.format())

        if self.mode == Move:
            self.gui.addstr(8, 2, "MOVE")
        else:
            self.gui.addstr(8, 2, "ATTACK", Colors.WhiteOnRed.format())

        if isinstance(subject.act, Inspect):
            self.gui.addstr(10, 2, f"Inspects {subject.act.subject.name}")

        self.gui.refresh()

    def wait_for_input(self, subject, vision):
        while True:
            hotkey = self.main.getkey()
            if hotkey in self.hotkeys:
                break
            log.debug(f"Ignored: [{hotkey}]")

        log.debug(f"[{hotkey}]")
        return self.hotkeys[hotkey](subject, vision, self)


def generate_default_hotkeys():
    result = {}

    class _hotkey:
        def __init__(self, *hotkeys):
            self.hotkeys = hotkeys

        def __call__(self, f):
            for hotkey in self.hotkeys:
                result[hotkey] = f

    def generate_movement_function(keys, direction):
        @_hotkey(*keys)
        def _(subject, vision, io):
            if vision.get(subject.p + direction) is None:
                act = Move
            else:
                act = io.mode

            return act(direction)

    for keys, direction in {
        ("w", ): up,
        ("s", ): down,
        ("a", ): left,
        ("d", ): right,
    }.items():
        generate_movement_function(keys, direction)

    @_hotkey("Q")
    def quit_(subject, vision, io):
        sys.exit()

    @_hotkey("r")
    def change_mode(subject, vision, io):
        io.mode = (io.mode == Move) and Attack or Move

    @_hotkey("KEY_MOUSE")
    def inspect(subject, vision, io):
        _, mx, my, _, _ = curses.getmouse()
        target = vision.get(io.virtual_p + Vector(mx, my))
        return target and Inspect(target)

    return result
