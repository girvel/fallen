import curses

from jinja2 import Environment, PackageLoader

from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.engine.inspect import inspect
from src.engine.output.colors import ColorPair, yellow
from src.engine.output.html import CursesHtmlRenderer
from src.lib.limited import Limited
from src.lib.query import Query
from src.lib.toolkit import from_snake_case


class Panel:
    mode = Move

    def __init__(self, w, io):
        self._window = curses.newwin(1, 1, 0, 0)
        self.w = w
        self.io = io

        self.panes = [
            self._controls,
            self._stats,
            self._quests,
        ]

        self.pane_i = Limited(len(self.panes), 0, 1)

        self.html_renderer = CursesHtmlRenderer()

        env = Environment(loader=PackageLoader(__name__), autoescape=True)

        self.stats_template = env.get_template("stats.html")
        self.controls_template = env.get_template("controls.html")
        self.quests_template = env.get_template("quests.html")

    def resize(self, h, w):
        self._window.resize(h - 1, self.w)
        self._window.mvwin(0, w - self.w)

    def render(self, subject, perception, memory):
        if memory.in_cutscene: return

        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        self.panes[self.pane_i.current](subject, perception, memory)

        if not self.pane_i.is_min():
            self._window.addstr(h - 2, 2, "<", ColorPair(yellow).to_curses())
            self._window.addstr(h - 2, 4, from_snake_case(self.panes[self.pane_i.current - 1].__name__).capitalize())

        if not self.pane_i.is_max():
            name = from_snake_case(self.panes[self.pane_i.current + 1].__name__).capitalize()
            self._window.addstr(h - 2, w - 3, ">", ColorPair(yellow).to_curses())
            self._window.addstr(h - 2, w - 4 - len(name), name)

        self._window.refresh()

    def _stats(self, subject, perception, memory):
        inspected = "act" in subject and isinstance(subject.act, Inspect) and subject.act.subject or None
        self.html_renderer.render_template(self._window, 1, 2, self.stats_template,
            subject=subject,
            mode="MOVE" if self.mode == Move else "<rw>ATTACK</rw>",
            inspection=(subject := ~Query(subject).act.subject) and inspect(subject),
        )

    pretty_hotkeys = {
        curses.KEY_MOUSE: "🐭",
        curses.KEY_LEFT: "←",
        curses.KEY_RIGHT: "→",
        curses.KEY_UP: "↑",
        curses.KEY_DOWN: "↓",
        ord(" "): "␣",
        ord("\n"): "⏎",
        ord(""): "Esc",
    }

    def _controls(self, subject, perception, memory):
        def reduce_hotkeys(hotkey_collection):
            result = {}

            for (hotkey, f) in hotkey_collection.items():
                name = from_snake_case(f.__name__).capitalize()

                if name in result:
                    result[name] += ", " + self.pretty_hotkeys.get(hotkey, chr(hotkey))
                else:
                    result[name] = self.pretty_hotkeys.get(hotkey, chr(hotkey))

            return result

        self.html_renderer.render_template(self._window, 1, 2, self.controls_template,
            hotkeys={from_snake_case(mode).capitalize(): reduce_hotkeys(collection) for mode, collection in self.io.input.hotkeys}
        )

    def _quests(self, subject, perception, memory):
        self.html_renderer.render_template(self._window, 1, 2, self.quests_template,
            quests=memory._quests,
        )
