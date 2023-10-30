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
    def define(cls, collection: "dict[int, Hotkey]", keys: list[str | int], description: Optional[str] = None):
        def decorator(function: Callable[[IO, DynamicEntity, Perception], Optional[Action]]):
            for key in keys:
                key = ord(key) if isinstance(key, str) else key
                collection[key] = Hotkey(function, description or "", description is None)
            return function

        return decorator


class Key:
    ctrl_c = 3
    enter = 13


def generate_hotkeys(debug_mode):
    result = Entity(global_={}, game={}, options={}, notification={}, dialog_line={}, cutscene={})
    # TODO mode as string enum

    @Hotkey.define(result.global_, ["Q", 3] if debug_mode else ["Q"], "Выйти из игры")
    def quit_(io, subject, perception):
        raise GameEnd

    @Hotkey.define(result.global_, [curses.KEY_RESIZE])
    def resize_gui(io, subject, perception):
        io.output.resize()

    def generate_movement_function(key, direction, description):
        @Hotkey.define(result.game, [key], description)
        def move(io, subject, perception):
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

    description_by_key = {
        "w": "вверх",
        "s": "вниз",
        "a": "влево",
        "d": "вправо",
    }

    for key, direction in directions_by_key.items():
        generate_movement_function(key, direction, "Идти " + description_by_key[key])

    @Hotkey.define(result.game, ["r"], "Переключить атаку/движение")
    def change_mode(io, subject, perception):
        io.output.panel.mode = (io.output.panel.mode == Move) and Attack or Move

    @Hotkey.define(result.game, ["1"], "Сотворить поток огня")
    def cast_fire_flow(io, subject, perception):
        while (hotkey := chr(io.input.key_queue.read_key())) not in "wasd":
            if hotkey == "": return

        return CastFireFlow(directions_by_key[hotkey])

    @Hotkey.define(result.game, [curses.KEY_LEFT], "Предыдущая панель")
    def previous_pane(io, subject, perception):
        io.output.panel.pane_i.move(-1)

    @Hotkey.define(result.game, [curses.KEY_RIGHT], "Следующая панель")
    def next_pane(io, subject, perception):
        io.output.panel.pane_i.move(1)

    @Hotkey.define(result.game, [curses.KEY_MOUSE], "Присмотреться к объекту")
    def inspect(io, subject, perception):
        _, mx, my, _, _ = curses.getmouse()
        target = next((
            e for l in io.output.game.layers_display_order
            if (e := perception.vision[l].get(add2(io.output.game.virtual_p, (mx, my)))) is not None
        ), None)
        return target and Inspect(target)

    if debug_mode:
        @Hotkey.define(result.game, ["`"], "Открыть консоль отладки")
        def show_debug_console(io, subject, perception):
            io.output.console.visible ^= True
            if not io.output.console.visible: return

            while True:
                io.render(subject, perception)
                hotkey = io.input.key_queue.read_key()

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
                        "it": isinstance(subject.act, Inspect) and subject.act.subject or None,
                        "monitor": io.output.monitor.values,
                        "player": subject,
                        "perception": perception,
                        "io": io,
                        "tracker": tracker,
                    })
                except Exception as ex:
                    logging.error(f"Exception when executing console code", exc_info=ex)

            logging.info(f"Executing console code:\n```py\n{io.output.console.buffer}\n```")
            enclose_console_code(subject, perception, io)
            io.output.console.buffer = ""
            io.output.console.visible = False

    @Hotkey.define(result.options, ["w", curses.KEY_UP], "Сдвинуть курсор вверх")
    def move_cursor_up(io, subject, perception):
        io.memory.selected_option_i = (io.memory.selected_option_i - 1) % len(io.memory.options)

    @Hotkey.define(result.options, ["s", curses.KEY_DOWN], "Сдвинуть курсор вниз")
    def move_cursor_down(io, subject, perception):
        io.memory.selected_option_i = (io.memory.selected_option_i + 1) % len(io.memory.options)

    @Hotkey.define(result.options, [Key.enter, "e"], "Выбрать подсвеченный вариант")
    def submit(io, subject, perception):
        return io.memory.select_option()

    @Hotkey.define(result.notification, [Key.enter, "e"], "Закрыть уведомление")
    def submit(io, subject, perception):
        return NoAction()

    @Hotkey.define(result.dialog_line, [" "], "Перейти к следующей реплике")
    def next_(io, subject, perception):
        return NoAction()

    @Hotkey.define(result.dialog_line, [""], "Пропустить сцену")
    @Hotkey.define(result.cutscene, [""], "Пропустить сцену")
    def skip(io, subject, perception):
        io.memory.is_skipping = True
        return NoAction()

    @Hotkey.define(result.cutscene, [-1])
    def watch(io, subject, perception):
        if not io.memory.is_skipping and io.max_fps:
            time.sleep(max(0., 1 / io.max_fps - time.time() + io.input.last_t))
            io.input.last_t = time.time()
        return NoAction()

    return result


class GameEnd(BaseException): pass
