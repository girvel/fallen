import curses
import logging
import re
import time
from dataclasses import dataclass
from typing import Callable, Optional, IO

from ecs import Entity, DynamicEntity

from src.engine.acting.action import Action
from src.engine.acting.actions.attack import Attack
from src.engine.acting.actions.cast_fire_flow import CastFireFlow
from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.engine.acting.actions.no_action import NoAction
from src.lib.toolkit import curses_wrong_characters
from src.lib.vector import add2, up, down, left, right
from src.systems.ai import Perception


@dataclass
class Hotkey:
    function: Callable[[IO, DynamicEntity, Perception], Optional[Action]]
    description: str
    hidden: bool

    @classmethod
    def define(cls, collection: "dict[int, Hotkey]", keys: list[str | int], description: str, hidden: bool = False):
        def decorator(function: Callable[[IO, DynamicEntity, Perception], Optional[Action]]):
            for key in keys:
                key = ord(key) if isinstance(key, str) else key
                collection[key] = Hotkey(function, description, hidden)

        return decorator


class Key:
    ctrl_c = 3
    enter = 13


def generate_hotkeys(debug_mode):
    result = Entity(global_={}, game={}, options={}, notification={}, dialog_line={}, cutscene={})
    # TODO mode as string enum

    # @_hotkey_definition("global_", ["Q", 3] if debug_mode else ["Q"], )
    # def quit_(io, subject, perception, memory):
    #     raise GameEnd

    @Hotkey.define(result.global_, ["Q", 3] if debug_mode else ["Q"], "Quit the game")
    def quit_(io, subject, perception):
        raise GameEnd

    # @_hotkey_definition("global_", [curses.KEY_RESIZE])
    # def resize_gui(io, subject, perception, memory):
    #     io.output.resize()
    #
    # def generate_movement_function(key, direction):
    #     @_hotkey_definition("game", [key])
    #     def move(io, subject, perception, memory):
    #         if io.output.panel.mode == Move:
    #             return Move(direction)
    #
    #         if io.output.panel.mode == Attack:
    #             if (target := perception.vision[subject.layer].get(add2(subject.p, direction))) is not None:
    #                 return Attack(target)
    #             return Move(direction)
    #
    # directions_by_key = {
    #     "w": up,
    #     "s": down,
    #     "a": left,
    #     "d": right,
    # }
    #
    # for key, direction in directions_by_key.items():
    #     generate_movement_function(key, direction)
    #
    # @_hotkey_definition("game", ["r"])
    # def change_mode(io, subject, perception, memory):
    #     io.output.panel.mode = (io.output.panel.mode == Move) and Attack or Move
    #
    # @_hotkey_definition("game", ["1"])
    # def cast_fire_flow(io, subject, perception, memory):
    #     while (hotkey := chr(io.input.key_queue.read_key())) not in "wasd":
    #         if hotkey == "": return
    #
    #     return CastFireFlow(directions_by_key[hotkey])
    #
    # @_hotkey_definition("game", [curses.KEY_LEFT])
    # def previous_pane(io, subject, perception, memory):
    #     io.output.panel.pane_i.move(-1)
    #
    # @_hotkey_definition("game", [curses.KEY_RIGHT])
    # def next_pane(io, subject, perception, memory):
    #     io.output.panel.pane_i.move(1)
    #
    # @_hotkey_definition("game", [curses.KEY_MOUSE])
    # def inspect(io, subject, perception, memory):
    #     _, mx, my, _, _ = curses.getmouse()
    #     target = next((
    #         e for l in io.output.game.layers_display_order
    #         if (e := perception.vision[l].get(add2(io.output.game.virtual_p, (mx, my)))) is not None
    #     ), None)
    #     return target and Inspect(target)
    #
    # if debug_mode:
    #     @_hotkey_definition("game", ["`"])
    #     def show_debug_console(io, subject, perception, memory):
    #         io.output.console.visible ^= True
    #         if not io.output.console.visible: return
    #
    #         while True:
    #             io.render(subject, perception)
    #             hotkey = io.input.key_queue.read_key()
    #
    #             if hotkey == curses.CTL_ENTER: break
    #             if hotkey == curses.KEY_MOUSE: continue
    #
    #             hotkey = curses_wrong_characters.get(hotkey, chr(hotkey))
    #
    #             if hotkey == "":
    #                 io.output.console.buffer = io.output.console.buffer[:-1]
    #             elif isinstance(hotkey, str):
    #                 io.output.console.buffer += hotkey
    #
    #             if hotkey == "\n":
    #                 last_line_i = io.output.console.buffer.rfind("\n", 0, -1)
    #                 last_line_i = last_line_i if last_line_i != -1 else 0
    #                 last_indent = re.match(r"^(\s*)", io.output.console.buffer[last_line_i:]).group(1)
    #                 io.output.console.buffer += last_indent
    #
    #         def enclose_console_code(subject, perception, io):
    #             def tracker(f):
    #                 io.monitor_values[f.__name__] = f
    #
    #             try:
    #                 exec(io.output.console.buffer, {
    #                     "it": isinstance(subject.act, Inspect) and subject.act.subject or None,
    #                     "monitor": io.output.monitor.values,
    #                     "player": subject,
    #                     "perception": perception,
    #                     "io": io,
    #                     "tracker": tracker,
    #                 })
    #             except Exception as ex:
    #                 logging.error(f"Exception when executing console code", exc_info=ex)
    #
    #         logging.info(f"Executing console code:\n```py\n{io.output.console.buffer}\n```")
    #         enclose_console_code(subject, perception, io)
    #         io.output.console.buffer = ""
    #         io.output.console.visible = False
    #
    # @_hotkey_definition("options", ["w", curses.KEY_UP])
    # def move_cursor_up(io, subject, perception, memory):
    #     memory.selected_option_i = (memory.selected_option_i - 1) % len(memory.options)
    #
    # @_hotkey_definition("options", ["s", curses.KEY_DOWN])
    # def move_cursor_down(io, subject, perception, memory):
    #     memory.selected_option_i = (memory.selected_option_i + 1) % len(memory.options)
    #
    # @_hotkey_definition("options", [13, "e"])
    # def submit(io, subject, perception, memory):
    #     return memory.select_option()
    #
    # @_hotkey_definition("notification", [13, "e"])
    # def submit(io, subject, perception, memory):
    #     return NoAction()
    #
    # @_hotkey_definition("dialog_line", [" "])
    # def next_(io, subject, perception, memory):
    #     return NoAction()
    #
    # @_hotkey_definition("dialog_line", [""])
    # @_hotkey_definition("cutscene", [""])
    # def skip(io, subject, perception, memory):
    #     memory.is_skipping = True
    #     return NoAction()
    #
    # @_hotkey_definition("cutscene", [-1])
    # def watch(io, subject, perception, memory):
    #     if not memory.is_skipping and io.has_fixed_fps:
    #         time.sleep(max(0., .2 - time.time() + io.input.last_t))
    #         io.input.last_t = time.time()
    #     return NoAction()

    return result


class GameEnd(BaseException): pass
