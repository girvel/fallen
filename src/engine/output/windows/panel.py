import curses
import logging

from jinja2 import Environment, PackageLoader

from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.engine.acting.damage import potential_damage
from src.engine.input.hotkeys import Key
from src.engine.inspection import inspect
from src.engine.output.colors import ColorPair, yellow
from src.engine.output.html import CursesHtmlRenderer
from src.engine.output.html_window import HtmlWindow
from src.engine.output.windows.panes.stats import Stats
from src.lib.limited import Limited
from src.lib.query import Q
from src.lib.toolkit import from_snake_case


class Panel(HtmlWindow):
    package_name = __name__
    template_name = "panel.html"
    has_border = True

    mode = Move

    def __post_init__(self):
        self.panes = [
            # Stats(self.io),
        ]
        self.pane_i = Limited(len(self.panes), 0, 0)

    def get_arguments(self, subject, perception):
        return {
            "previous_pane_name": "Hello world!",
            "next_pane_name": "Hello world!",
        }

    def _render(self, subject, perception):
        super()._render(subject, perception)

    def _calculate_visibility(self, subject, perception):
        return not self.io.memory.in_cutscene

    def _responsive_size(self, subject, perception, max_size):
        return min(max_size[0] - 6, 35), max_size[1] - 2

    # def __init__(self, io):
    #     self._window = curses.newwin(1, 1, 0, 0)
    #     self.io = io
    #
    #     self.panes = [
    #         self._controls,
    #         self._stats,
    #         self._inventory,
    #         self._quests,
    #     ]
    #
    #     self.pane_i = Limited(len(self.panes), 0, 1)
    #
    #     self.html_renderer = CursesHtmlRenderer()
    #
    #     env = Environment(loader=PackageLoader(__name__), autoescape=True)
    #
    #     self.stats_template = env.get_template("stats.html")
    #     self.controls_template = env.get_template("controls.html")
    #     self.quests_template = env.get_template("quests.html")
    #     self.inventory_template = env.get_template("inventory.html")
    #
    # def render(self, subject, perception, max_size):
    #     if self.io.memory.in_cutscene: return
    #
    #     self._resize(max_size)
    #
    #     h, w = self._window.getmaxyx()
    #
    #     self._window.clear()
    #     self._window.border()
    #
    #     self.panes[self.pane_i.current](subject, perception)
    #
    #     if not self.pane_i.is_min():
    #         self._window.addstr(h - 2, 2, "<", ColorPair(yellow).to_curses())
    #         self._window.addstr(h - 2, 4, from_snake_case(self.panes[self.pane_i.current - 1].__name__).capitalize())
    #
    #     if not self.pane_i.is_max():
    #         name = from_snake_case(self.panes[self.pane_i.current + 1].__name__).capitalize()
    #         self._window.addstr(h - 2, w - 3, ">", ColorPair(yellow).to_curses())
    #         self._window.addstr(h - 2, w - 4 - len(name), name)
    #
    #     self._window.refresh()
    #
    # def _resize(self, max_size):
    #     self._window.resize(max_h - 1, self.w)
    #     self._window.mvwin(0, max_w - self.w)
    #
    # def _stats(self, subject, perception):
    #     self.html_renderer.render_template(self._window, 1, 2, self.stats_template,
    #         subject=subject,
    #         potential_damage=int(potential_damage(subject)),
    #         mode="MOVE" if self.mode == Move else "<rw>ATTACK</rw>",
    #         inspection=(inspected := ~Q(subject).act[Inspect].subject) and inspect(inspected),
    #     )
    #
    # pretty_hotkeys = {
    #     curses.KEY_MOUSE: "🐭",
    #     curses.KEY_LEFT: "←",
    #     curses.KEY_RIGHT: "→",
    #     curses.KEY_UP: "↑",
    #     curses.KEY_DOWN: "↓",
    #     ord(" "): "␣",
    #     Key.enter: "⏎",
    #     Key.ctrl_c: "Ctrl+C",
    #     ord(""): "Esc",
    # }
    #
    # def _controls(self, subject, perception):
    #     def reduce_hotkeys(hotkey_collection):
    #         result = {}
    #
    #         for (key, hotkey) in hotkey_collection.items():
    #             if hotkey.hidden: continue
    #             entry = self.pretty_hotkeys.get(key, chr(key) if key != -1 else " ")
    #
    #             if hotkey.description in result:
    #                 result[hotkey.description] += ", " + entry
    #             else:
    #                 result[hotkey.description] = entry
    #
    #         return result
    #
    #     mode_translation = {  # TODO move to the Mode itself
    #         "global_": "Глобальные",
    #         "game": "Игра",
    #         "options": "Выбор варианта",
    #         "dialog_line": "Диалог",
    #         "cutscene": "Сцена",
    #         "notification": "Уведомление",
    #     }
    #
    #     self.html_renderer.render_template(self._window, 1, 2, self.controls_template,
    #         hotkeys={
    #             mode_translation[mode]: reduce_hotkeys(self.io.input.hotkeys[mode])
    #             for mode
    #             in ["global_", "game", "options", "dialog_line", "cutscene", "notification"]
    #         }
    #     )
    #
    # def _quests(self, subject, perception):
    #     self.html_renderer.render_template(self._window, 1, 2, self.quests_template,
    #         quests=self.io.memory.get_quests(),
    #     )
    #
    # def _inventory(self, subject, perception):
    #     self.html_renderer.render_template(self._window, 1, 2, self.inventory_template,
    #         inventory=subject.inventory,
    #     )
