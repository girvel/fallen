import curses
import logging
import re
import time
from typing import TYPE_CHECKING

from src.engine.acting.actions.attack import Attack
from src.engine.acting.actions.cast_fire_flow import CastFireFlow
from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.lib.toolkit import curses_wrong_characters
from src.lib.vector import add2, up, down, left, right
from src.systems.ai import Perception

if TYPE_CHECKING:
    from src.entities.ais.io import Memory


class Input:
    def __init__(self, stdscr, debug_track, debug_mode, io):
        # TODO hotkey is actionable if it returns True
        stdscr.nodelay(1)

        self.main = stdscr
        self.io = io

        if debug_track:
            self.debug_track = iter(debug_track)
            logging.info(f"Debug track: '{debug_track}'")
        else:
            self.debug_track = None

        self.action_hotkeys, self.other_hotkeys = generate_default_hotkeys(debug_mode)
        self.option_hotkeys = generate_option_hotkeys()
        self.submit_hotkey = {ord("\n"), ord("e")}
        self.next_hotkey = {ord(" ")}
        self.skip_hotkey = {ord("")}

        logging.info(f"Initalized mouse with {curses.mousemask(curses.ALL_MOUSE_EVENTS)}")

    def wait_for_input(self, subject, perception: Perception, memory: "Memory"):
        if memory.in_cutscene:
            if memory.options:
                if not memory.is_skipping or len(memory.options) != 1:
                    while (key := self.main.getch()) not in self.submit_hotkey:
                        if (f := self.option_hotkeys.get(key)) is not None:
                            f(memory)
                            self.io.render(subject, perception)
                else:
                    memory.selected_option_i = 0

                result = list(memory.options.values())[memory.selected_option_i]
                memory.last_selected_option = list(memory.options.keys())[memory.selected_option_i]
                memory.options = None
                memory.selected_option_i = 0
                return result

            if memory.current_sound is not None:
                while not memory.is_skipping and (key := self.main.getch()) not in self.next_hotkey:
                    if key in self.skip_hotkey: memory.is_skipping = True
                return

            if not memory.is_skipping: time.sleep(0.2)  # TODO flexible
            return

        if self.io.output.notification.visible:
            while (key := self.main.getch()) not in self.submit_hotkey: pass
            self.io.rerender()

        while True:
            if self.debug_track is not None:
                hotkey = ord(next(self.debug_track))
            else:
                hotkey = self.main.getch()

            if hotkey in self.action_hotkeys: break

            if hotkey in self.other_hotkeys:
                self.other_hotkeys[hotkey](subject, perception, self.io)
                self.io.render(subject, perception)
                continue

        return self.action_hotkeys[hotkey](subject, perception, self.io)


def generate_default_hotkeys(debug_mode):
    action_hotkeys = {}
    other_hotkeys = {}

    class _hotkey:
        def __init__(self, *keys, non_action=False):
            self.keys = keys
            self.non_action = non_action

        def __call__(self, f):
            for hotkey in self.keys:
                (other_hotkeys if self.non_action else action_hotkeys)[
                    ord(hotkey) if isinstance(hotkey, str) else hotkey
                ] = f

    def generate_movement_function(key, direction):
        @_hotkey(key)
        def move(subject, perception, io):
            if io.output.panel.mode == Move:
                return Move(direction)

            if io.output.panel.mode == Attack:
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
        raise KeyboardInterrupt

    @_hotkey("r")
    def change_mode(subject, perception, io):
        io.output.panel.mode = (io.output.panel.mode == Move) and Attack or Move

    @_hotkey("1")
    def cast_fire_flow(subject, perception, io):
        while True:
            while (hotkey := io.input.main.getch()) == -1: pass
            hotkey = chr(hotkey)

            if hotkey in "wasd": break
            if hotkey == "": return

        return CastFireFlow(directions_by_key[hotkey])

    @_hotkey(curses.KEY_LEFT, non_action=True)
    def previous_pane(subject, perception, io):
        io.output.panel.pane_i.move(-1)

    @_hotkey(curses.KEY_RIGHT, non_action=True)
    def next_pane(subject, perception, io):
        io.output.panel.pane_i.move(1)

    @_hotkey(curses.KEY_MOUSE)
    def inspect(subject, perception, io):
        _, mx, my, _, _ = curses.getmouse()
        target = next((
            e for l in io.output.game.layers_display_order
            if (e := perception.vision[l].get(add2(io.output.game.virtual_p, (mx, my)))) is not None
        ), None)
        return target and Inspect(target)

    @_hotkey(curses.KEY_RESIZE, non_action=True)
    def resize_gui(subject, perception, io):
        io.output.resize()

    if debug_mode:
        @_hotkey("`", non_action=True)
        def show_debug_console(subject, perception, io):
            io.output.console.visible ^= True
            if not io.output.console.visible: return

            while True:
                io.render(subject, perception)
                while (hotkey := io.input.main.getch()) == -1: pass

                if hotkey == curses.CTL_ENTER: break
                if hotkey == curses.KEY_MOUSE: continue

                hotkey = curses_wrong_characters.get(hotkey, chr(hotkey))

                if hotkey == "":
                    io.output.console.buffer = io.output.console.buffer[:-1]
                elif isinstance(hotkey, str):
                    io.output.console.buffer += hotkey

                if hotkey == "\n":
                    last_line_i = io.output.console.buffer.rfind("\n", 0, -1)
                    last_line_i = last_line_i if last_line_i != -1 else 0
                    last_indent = re.match(r"^(\s*)", io.output.console.buffer[last_line_i:]).group(1)
                    io.output.console.buffer += last_indent

            def enclose_console_code(subject, perception, io):
                def tracker(f):
                    io.monitor_values[f.__name__] = f

                try:
                    exec(io.output.console.buffer, {
                        "it": lambda: (isinstance(subject.act, Inspect) and subject.act.subject or None),
                        "monitor": io.output.monitor.values,
                        "player": subject,
                        "perception": perception,
                        "io": io,
                        "tracker": tracker,
                        "level": io.level,
                    })
                except Exception as ex:
                    logging.warning(f"Exception when executing console code")
                    logging.exception(ex)

            logging.info(f"Executing console code:\n```py\n{io.output.console.buffer}\n```")
            enclose_console_code(subject, perception, io)
            io.output.console.buffer = ""
            io.output.console.visible = False

    return action_hotkeys, other_hotkeys


def generate_option_hotkeys():
    result = {}

    class _hotkey:
        def __init__(self, *keys):
            self.keys = keys

        def __call__(self, f):
            for hotkey in self.keys:
                result[ord(hotkey) if isinstance(hotkey, str) else hotkey] = f

    @_hotkey("w", curses.KEY_UP)
    def move_cursor_up(memory):
        memory.selected_option_i = (memory.selected_option_i - 1) % len(memory.options)

    @_hotkey("s", curses.KEY_DOWN)
    def move_cursor_down(memory):
        memory.selected_option_i = (memory.selected_option_i + 1) % len(memory.options)

    return result