import curses
import time
from dataclasses import dataclass
from typing import Callable, Optional, IO

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.library.actions.hand_attack import HandAttack
from src.library.actions.cast_fire_flow import CastFireFlow
from src.library.actions.inspect import Inspect
from src.library.actions.move import Move
from src.library.actions.no_action import NoAction
from src.engine.input.mode import ALL_MODES, GENERAL, GAME, OPTIONS, NOTIFICATION, DIALOGUE_LINE, CUTSCENE
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
    result = {mode: {} for mode in ALL_MODES}

    @Hotkey.define(result[GENERAL], ["Q", 3] if debug_mode else ["Q"], "Выйти из игры")
    def quit_(io, subject, perception):
        raise GameEnd

    @Hotkey.define(result[GENERAL], [curses.KEY_RESIZE])
    def resize_gui(io, subject, perception):
        pass

    def generate_movement_function(key, direction, description):
        @Hotkey.define(result[GAME], [key], description)
        def move(io, subject, perception):
            if io.output.panel.mode == Move:
                return Move(direction)

            if io.output.panel.mode == HandAttack:
                if (target := perception.vision[subject.layer].get(add2(subject.p, direction))) is not None:
                    return HandAttack(target)
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

    @Hotkey.define(result[GAME], ["r"], "Переключить атаку/движение")
    def change_mode(io, subject, perception):
        io.output.panel.mode = (io.output.panel.mode == Move) and HandAttack or Move

    @Hotkey.define(result[GAME], ["1"], "Сотворить поток огня")
    def cast_fire_flow(io, subject, perception):
        while (hotkey := chr(io.input.key_queue.read_key())) not in "wasd":
            if hotkey == "": return

        return CastFireFlow(directions_by_key[hotkey])

    @Hotkey.define(result[GAME], [curses.KEY_LEFT], "Предыдущая панель")
    def previous_pane(io, subject, perception):
        io.output.panel.pane_i.move(-1)

    @Hotkey.define(result[GAME], [curses.KEY_RIGHT], "Следующая панель")
    def next_pane(io, subject, perception):
        io.output.panel.pane_i.move(1)

    @Hotkey.define(result[GAME], [curses.KEY_UP], "Прокрутить панель вверх")
    def scroll_up(io, subject, perception):
        panel = io.output.panel
        panel.panes[panel.pane_i.current].scroll.move(-1)

    @Hotkey.define(result[GAME], [curses.KEY_DOWN], "Прокрутить панель вниз")
    def scroll_down(io, subject, perception):
        panel = io.output.panel
        panel.panes[panel.pane_i.current].scroll.move(1)

    @Hotkey.define(result[GAME], [curses.KEY_MOUSE], "Присмотреться к объекту")
    def inspect(io, subject, perception):
        _, mx, my, _, _ = curses.getmouse()
        target = next((
            e for l in io.output.game.layers_display_order
            if (e := perception.vision[l].get(add2(io.output.game.virtual_p, (mx, my)))) is not None
        ), None)
        return target and Inspect(target)

    @Hotkey.define(result[OPTIONS], ["w", curses.KEY_UP], "Сдвинуть курсор вверх")
    def move_cursor_up(io, subject, perception):
        io.memory.selected_option_i = max(io.memory.selected_option_i - 1, 0)

    @Hotkey.define(result[OPTIONS], ["s", curses.KEY_DOWN], "Сдвинуть курсор вниз")
    def move_cursor_down(io, subject, perception):
        io.memory.selected_option_i = min(io.memory.selected_option_i + 1, len(io.memory.options) - 1)

    @Hotkey.define(result[OPTIONS], [Key.enter, "e"], "Выбрать подсвеченный вариант")
    def submit(io, subject, perception):
        return io.memory.select_option()

    @Hotkey.define(result[NOTIFICATION], [Key.enter, "e"], "Закрыть уведомление")
    def submit(io, subject, perception):
        return NoAction()

    @Hotkey.define(result[DIALOGUE_LINE], [" "], "Перейти к следующей реплике")
    def next_(io, subject, perception):
        return NoAction()

    @Hotkey.define(result[DIALOGUE_LINE], [""], "Пропустить сцену")
    @Hotkey.define(result[CUTSCENE], [""], "Пропустить сцену")
    def skip(io, subject, perception):
        io.memory.is_skipping = True
        return NoAction()

    @Hotkey.define(result[CUTSCENE], [-1])
    def watch(io, subject, perception):
        if not io.memory.is_skipping and io.max_fps:
            time.sleep(max(0., 1 / io.max_fps - time.time() + io.input.last_t))
            io.input.last_t = time.time()
        return NoAction()

    return result


class GameEnd(BaseException): pass
