import curses
import sys
from enum import Enum
from statistics import median

from ecs import OwnedEntity

from src.lib.toolkit import cut_by_length
from src.lib.vector import zero, up, down, left, right, add2, le2, lt2, floordiv2, sub2, safe_get2, size2

import logging

from src.systems.acting.actions.attack import Attack
from src.systems.acting.actions.inspect import Inspect
from src.systems.acting.actions.move import Move

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
    virtual_p = (0, 0)
    following_offset = (0, 0)  # modified on resize
    gui_w = 35
    monitor_h = 8
    level = None

    # output
    mode = Move

    def __init__(self, stdscr, debug_track, debug_mode):
        self.main = stdscr
        self.game = curses.newwin(1, 1, 0, 0)
        self.gui = curses.newwin(1, 1, 0, 0)
        self.debug_monitor = curses.newwin(1, 1, 0, 0)
        self.console = curses.newwin(1, 1, 0, 0)
        self.console_visible = False

        self.debug_track = debug_track and iter(debug_track)
        self.debug_mode = debug_mode

        self.monitor_values = {"demo": lambda: self.main.getmaxyx()}
        self.console_buffer = ""

        self.action_hotkeys, self.other_hotkeys = generate_default_hotkeys()

        log.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        print('\033[?1003h')

        curses.init_pair(Colors.Red.value, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(Colors.Green.value, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnBlue.value, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(Colors.Yellow.value, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(Colors.WhiteOnRed.value, curses.COLOR_WHITE, curses.COLOR_RED)

    def connect_to_level(self, level):
        self.level = level

    def make_decision(self, subject, perception):
        self.render(subject, perception)
        return self._wait_for_input(subject, perception)

    def render(self, subject, perception):
        self._resize_windows()
        self._move_camera(subject)
        self._display_perception(subject, perception)
        self._display_gui(subject)

        if self.debug_mode:
            self._display_debug_monitor()
            if self.console_visible:
                self._display_console()

    # STAGES #

    def _resize_windows(self):
        # TODO as a reaction to event, not on update
        h, w = self.main.getmaxyx()

        self.game.resize(h - 1, w - self.gui_w)
        self.following_offset = floordiv2((w - self.gui_w, h - 1), 3)

        self.gui.resize(h - 1, self.gui_w)
        self.gui.mvwin(0, w - self.gui_w)

        if self.debug_mode:
            self.debug_monitor.resize(self.monitor_h, self.gui_w)
            self.debug_monitor.mvwin(0, 0)

            self.console.resize(h - 1, self.gui_w)
            self.console.mvwin(0, w - self.gui_w)

    def _move_camera(self, subject):
        screen_h, screen_w = self.game.getmaxyx()
        level_w, level_h = size2(self.level.physical_grid)

        self.virtual_p = (
            median((
                0,
                subject.p[0] - screen_w + self.following_offset[0],
                self.virtual_p[0],
                subject.p[0] - self.following_offset[0],
                level_w - screen_w,
            )),
            median((
                0,
                subject.p[1] - screen_h + self.following_offset[1],
                self.virtual_p[1],
                subject.p[1] - self.following_offset[1],
                level_h - screen_h,
            ))
        )

    def _display_perception(self, subject, perception):
        self.game.clear()
        h, w = self.game.getmaxyx()
        screen_size = (w - 1, h)

        for p, entity in perception.vision.items():
            p_on_screen = sub2(p, self.virtual_p)
            if not (le2(zero, p_on_screen) and lt2(p_on_screen, screen_size)): continue

            if entity is not None:
                character = entity.character
                color = get_color_pair(entity) | (
                    "act" in subject and isinstance(subject.act, Inspect) and subject.act.subject == entity
                        and curses.A_REVERSE
                        or 0
                ) | curses.A_BOLD
            elif (effect := safe_get2(self.level.effect_grid, p)) is not None:
                character = effect.character
                color = effect.color.format()
            elif (tile := safe_get2(self.level.tile_grid, p)) is not None:
                character = tile.character
                color = tile.color.format() | curses.A_BOLD
            else:
                character = "."
                color = Colors.Default.format()

            self.game.addch(p_on_screen[1], p_on_screen[0], character, color)

        self.game.refresh()

    def _display_gui(self, subject):
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

        if "act" in subject and isinstance(subject.act, Inspect):
            self.gui.addstr(10, 2, f"Inspects {subject.act.subject.name}")

        self.gui.refresh()

    def _display_debug_monitor(self):
        self.debug_monitor.clear()
        self.debug_monitor.border()

        for i, (header, f) in enumerate(self.monitor_values.items()):
            self.debug_monitor.addstr(1 + i, 1, f"{header}:")
            self.debug_monitor.addstr(1 + i, 1 + len(header) + 2, repr(f()), Colors.Yellow.format())

            if i >= self.monitor_h - 2:
                break

        self.debug_monitor.refresh()

    def _display_console(self):
        self.console.clear()
        self.console.border()

        for i, string in enumerate(
            sum(map(lambda s: cut_by_length(s, self.gui_w - 2), self.console_buffer.split("\n")), start=[])
        ):
            self.console.addstr(1 + i, 1, string)

        self.console.refresh()

    def _wait_for_input(self, subject, perception):
        while True:
            if self.debug_track is not None:
                hotkey = next(self.debug_track)
            else:
                hotkey = self.main.getkey()

            if hotkey in self.action_hotkeys:
                log.debug(f"[{hotkey}] -> {self.action_hotkeys[hotkey].__name__}")
                break

            if hotkey in self.other_hotkeys:
                log.debug(f"[{hotkey}] -> no action")
                self.other_hotkeys[hotkey](subject, perception, self)
                continue

            log.debug(f"Ignored [{hotkey}]")

        return self.action_hotkeys[hotkey](subject, perception, self)


def generate_default_hotkeys():
    action_hotkeys = {}
    other_hotkeys = {}

    class _hotkey:
        def __init__(self, *keys, non_action=False):
            self.keys = keys
            self.non_action = non_action

        def __call__(self, f):
            for hotkey in self.keys:
                (other_hotkeys if self.non_action else action_hotkeys)[hotkey] = f

    def generate_movement_function(keys, direction):
        @_hotkey(*keys)
        def move(subject, perception, io):
            if io.mode == Move:
                return Move(direction)

            if io.mode == Attack:
                if (target := perception.vision.get(add2(subject.p, direction))) is not None:
                    return Attack(target)
                return Move(direction)

    for keys, direction in {
        ("w", ): up,
        ("s", ): down,
        ("a", ): left,
        ("d", ): right,
    }.items():
        generate_movement_function(keys, direction)

    @_hotkey("Q")
    def quit_(subject, perception, io):
        sys.exit()

    @_hotkey("r")
    def change_mode(subject, perception, io):
        io.mode = (io.mode == Move) and Attack or Move

    @_hotkey("KEY_MOUSE")
    def inspect(subject, perception, io):
        _, mx, my, _, _ = curses.getmouse()
        target = perception.vision.get(add2(io.virtual_p, (mx, my)))
        return target and Inspect(target)

    @_hotkey("`", non_action=True)
    def show_debug_console(subject, perception, io):
        io.console_visible ^= True
        if not io.console_visible: return

        while True:
            io.render(subject, perception)
            if (hotkey := io.main.getkey()) == "CTL_ENTER": break

            if len(hotkey) != 1: continue
            if hotkey == "":
                io.console_buffer = io.console_buffer[:-1]
            else:
                io.console_buffer += hotkey

        def enclose_monitor_function(buffer):
            def monitor_function():
                try:
                    return eval(buffer)
                except Exception as ex:
                    return ex
            return monitor_function

        log.info(f"Adding monitor function:\n```py\n{io.console_buffer}\n```")
        io.monitor_values[str(len(io.monitor_values))] = enclose_monitor_function(io.console_buffer)
        io.console_buffer = ""
        io.console_visible = False
        io.render(subject, perception)

    return action_hotkeys, other_hotkeys
