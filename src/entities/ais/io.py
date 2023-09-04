import curses
import re
import sys
from statistics import median

from ecs import OwnedEntity, Entity

from src.entities.ais.iolib.colors import Colors, get_color_pair
from src.entities.ais.iolib.gui import Gui
from src.lib.toolkit import cut_by_length, curses_wrong_characters
from src.lib.vector import zero, up, down, left, right, add2, le2, lt2, floordiv2, sub2, safe_get2, size2

import logging

from src.systems.acting.actions.attack import Attack
from src.systems.acting.actions.cast_fire_flow import CastFireFlow
from src.systems.acting.actions.inspect import Inspect
from src.systems.acting.actions.move import Move


class IO(OwnedEntity):
    name = 'Input/Output'

    # input
    # virtual_p = (0, 0)
    # following_offset = (0, 0)  # modified on resize
    # gui_w = 35
    # monitor_h = 8
    level = None

    # output
    # mode = Move

    def __init__(self, stdscr, debug_track, debug_mode):
        self.gui = Gui(stdscr, debug_mode)
        self.gui.resize()
        self.main = stdscr

        # self.game = curses.newwin(1, 1, 0, 0)
        # self.gui = curses.newwin(1, 1, 0, 0)
        # self.debug_monitor = curses.newwin(1, 1, 0, 0)
        # self.console = curses.newwin(1, 1, 0, 0)
        # self.console_visible = False

        self.debug_track = debug_track and iter(debug_track)
        # self.debug_mode = debug_mode

        # self.monitor_values = Entity()
        # self.console_buffer = ""

        self.action_hotkeys, self.other_hotkeys = generate_default_hotkeys(debug_mode)

        logging.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")
        print('\033[?1003h')

        Colors.initialize()

        # self.resize()

    def connect_to_level(self, level):
        self.level = level

    def make_decision(self, subject, perception):
        self.render(subject, perception)
        return self._wait_for_input(subject, perception)

    def render(self, subject, perception):
        self.gui.render(subject, perception, self.level)
        # # self.main.refresh()
        # # self._move_camera(subject)
        # # self._display_perception(subject, perception)
        # # self._display_gui(subject)
        #
        # # if not self.debug_mode: return
        #
        # if len(self.monitor_values) > 0:
        #     self._display_debug_monitor()
        #
        # if self.console_visible:
        #     self._display_console()

    # STAGES #

    # def resize(self):
        # h, w = self.main.getmaxyx()

        # self.game.resize(h - 1, w - self.gui_w)
        # self.following_offset = floordiv2((w - self.gui_w, h - 1), 3)

        # self.gui.resize(h - 1, self.gui_w)
        # self.gui.mvwin(0, w - self.gui_w)
        #
        # if self.debug_mode:
        #     # self.debug_monitor.resize(self.monitor_h, self.gui_w)
        #     # self.debug_monitor.mvwin(0, 0)
        #
        #     self.console.resize(h - 1, self.gui_w)
        #     self.console.mvwin(0, w - self.gui_w)

    # def _move_camera(self, subject):
    #     screen_h, screen_w = self.game.getmaxyx()
    #     level_w, level_h = size2(self.level.grids.physical)
    #
    #     self.virtual_p = (
    #         median((
    #             0,
    #             subject.p[0] - screen_w + self.following_offset[0],
    #             self.virtual_p[0],
    #             subject.p[0] - self.following_offset[0],
    #             level_w - screen_w,
    #         )),
    #         median((
    #             0,
    #             subject.p[1] - screen_h + self.following_offset[1],
    #             self.virtual_p[1],
    #             subject.p[1] - self.following_offset[1],
    #             level_h - screen_h,
    #         ))
    #     )
    #
    # layers_display_order = ["physical", "effects", "tiles"]
    #
    # def _display_perception(self, subject, perception):
    #     self.game.clear()
    #     h, w = self.game.getmaxyx()
    #     screen_size = (w - 1, h)
    #
    #     for rx in range(0, screen_size[0]):
    #         for ry in range(0, screen_size[1]):
    #             character = safe_get2(subject.spacial_memory, add2((rx, ry), self.virtual_p))
    #             self.game.addch(ry, rx, character not in {None, "."} and character or " ")
    #
    #     inspected = isinstance(subject.act, Inspect) and subject.act.subject
    #     for p in perception.vision.physical:
    #         rp = sub2(p, self.virtual_p)
    #         if not (le2(zero, rp) and lt2(rp, screen_size)): continue
    #
    #         for layer in self.layers_display_order:
    #             if (entity := safe_get2(self.level.grids[layer], p)) is None: continue
    #
    #             character = entity.character
    #             color = get_color_pair(entity) | (
    #                 inspected == entity
    #                     and curses.A_REVERSE
    #                     or 0
    #             )
    #             break
    #         else:
    #             character = "."
    #             color = Colors.Default.format()
    #
    #         self.game.addch(rp[1], rp[0], character, color)
    #
    #     self.game.refresh()

    # def _display_gui(self, subject):
    #     self.gui.clear()
    #     self.gui.border()
    #
    #     name_tag = f"\__ {subject.name} __/"
    #
    #     self.gui.addstr(1, 2, " " * ((self.gui_w - 2 - len(name_tag)) // 2) + name_tag, curses.A_BOLD)
    #     self.gui.addstr(4, 2, f"Health: ")
    #     self.gui.addstr(4, 10,
    #         f"{subject.health.amount.current}/{subject.health.amount.maximum}",
    #         Colors.Yellow.format()
    #     )
    #     self.gui.addstr(5, 2, f"Armor: ")
    #     self.gui.addstr(5, 10, subject.health.armor_kind, Colors.Yellow.format())
    #     self.gui.addstr(6, 2, f"Damage: ")
    #     self.gui.addstr(6, 10, f"{subject.weapon.power} {subject.weapon.damage_kind}", Colors.Yellow.format())
    #
    #     if self.mode == Move:
    #         self.gui.addstr(8, 2, "MOVE")
    #     else:
    #         self.gui.addstr(8, 2, "ATTACK", Colors.WhiteOnRed.format())
    #
    #     if "act" in subject and isinstance(subject.act, Inspect):
    #         inspected = subject.act.subject
    #
    #         self.gui.addstr(10, 2, f"Inspects")
    #         self.gui.addstr(10, 11, inspected.name, Colors.Yellow.format())
    #
    #         if "health" in inspected and inspected.health.amount.current <= inspected.health.amount.maximum / 2:
    #             self.gui.addstr(11, 2, "Looks hurt", Colors.Yellow.format())
    #
    #     self.gui.refresh()
    #
    # def _display_debug_monitor(self):
    #     self.debug_monitor.clear()
    #     self.debug_monitor.border()
    #
    #     for i, (header, f) in enumerate(self.monitor_values):
    #         self.debug_monitor.addstr(1 + i, 1, f"{header}:")
    #
    #         try:
    #             value = f()
    #         except Exception as ex:
    #             value = ex
    #
    #         self.debug_monitor.addstr(1 + i, 1 + len(header) + 2, repr(value), Colors.Yellow.format())
    #
    #         if i >= self.monitor_h - 2:
    #             break
    #
    #     self.debug_monitor.refresh()
    #
    # def _display_console(self):
    #     self.console.clear()
    #     self.console.border()
    #
    #     for i, string in enumerate(
    #         sum(map(lambda s: cut_by_length(s, self.gui_w - 2), self.console_buffer.split("\n")), start=[])
    #     ):
    #         self.console.addstr(1 + i, 1, string)
    #
    #     self.console.refresh()

    def _wait_for_input(self, subject, perception):
        while True:
            if self.debug_track is not None:
                hotkey = next(self.debug_track)
            else:
                hotkey = self.main.getkey()

            if hotkey in self.action_hotkeys:
                logging.debug(f"[{hotkey}] -> {self.action_hotkeys[hotkey].__name__}")
                break

            if hotkey in self.other_hotkeys:
                logging.debug(f"[{hotkey}] -> no action")
                self.other_hotkeys[hotkey](subject, perception, self)
                continue

            logging.debug(f"Ignored [{hotkey}]")

        return self.action_hotkeys[hotkey](subject, perception, self)


def generate_default_hotkeys(debug_mode):
    action_hotkeys = {}
    other_hotkeys = {}

    class _hotkey:
        def __init__(self, *keys, non_action=False):
            self.keys = keys
            self.non_action = non_action

        def __call__(self, f):
            for hotkey in self.keys:
                (other_hotkeys if self.non_action else action_hotkeys)[hotkey] = f

    def generate_movement_function(key, direction):
        @_hotkey(key)
        def move(subject, perception, io):
            if io.gui.panel.mode == Move:
                return Move(direction)

            if io.gui.panel.mode == Attack:
                if (target := perception.vision[subject.layer].get(add2(subject.p, direction))) is not None:
                    return Attack(target)
                return Move(direction)

    directions_by_key = {
        "w": up,
        "s": down,
        "a": left,
        "d": right,
    }

    for key, direction in directions_by_key.items():
        generate_movement_function(key, direction)

    @_hotkey("Q")
    def quit_(subject, perception, io):
        sys.exit()

    @_hotkey("r")
    def change_mode(subject, perception, io):
        io.gui.panel.mode = (io.gui.panel.mode == Move) and Attack or Move

    @_hotkey("1")
    def cast_fire_flow(subject, perception, io):
        while not isinstance((hotkey := io.main.get_wch()), str) or hotkey not in "wasd":
            if hotkey == "":
                return
        return CastFireFlow(directions_by_key[hotkey])

    @_hotkey("KEY_MOUSE")
    def inspect(subject, perception, io):
        _, mx, my, _, _ = curses.getmouse()
        target = next((
            e for l in io.gui.game.layers_display_order
            if (e := perception.vision[l].get(add2(io.gui.game.virtual_p, (mx, my)))) is not None
        ), None)
        return target and Inspect(target)

    @_hotkey("KEY_RESIZE", non_action=True)
    def resize_gui(subject, perception, io):
        io.gui.resize()
        io.render(subject, perception)

    if debug_mode:
        @_hotkey("`", non_action=True)
        def show_debug_console(subject, perception, io):
            io.gui.console.visible ^= True
            if not io.gui.console.visible: return

            while True:
                io.render(subject, perception)
                if (
                    (hotkey := io.main.get_wch()) and
                    (hotkey := curses_wrong_characters.get(
                        isinstance(hotkey, int) and hotkey or ord(hotkey), hotkey)
                    ) == "CTL_ENTER"
                ): break

                if hotkey == "":
                    io.gui.console.buffer = io.gui.console.buffer[:-1]
                elif isinstance(hotkey, str):
                    io.gui.console.buffer += hotkey

                if hotkey == "\n":
                    last_line_i = io.gui.console.buffer.rfind("\n", 0, -1)
                    last_line_i = last_line_i if last_line_i != -1 else 0
                    last_indent = re.match(r"^(\s*)", io.gui.console.buffer[last_line_i:]).group(1)
                    io.gui.console.buffer += last_indent

            def enclose_console_code(subject, perception, io):
                def tracker(f):
                    io.monitor_values[f.__name__] = f

                try:
                    exec(io.gui.console.buffer, {
                        "it": lambda: (isinstance(subject.act, Inspect) and subject.act.subject or None),
                        "monitor": io.gui.monitor.values,
                        "subject": subject,
                        "perception": perception,
                        "io": io,
                        "tracker": tracker,
                        "level": io.level,
                    })
                except Exception as ex:
                    logging.warning(f"Exception when executing console code")
                    logging.exception(ex)

            logging.info(f"Executing console code:\n```py\n{io.gui.console.buffer}\n```")
            enclose_console_code(subject, perception, io)
            io.gui.console.buffer = ""
            io.gui.console.visible = False
            io.render(subject, perception)

    return action_hotkeys, other_hotkeys
