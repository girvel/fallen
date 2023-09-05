import curses
import logging
import re
from html.parser import HTMLParser

from jinja2 import Environment, PackageLoader, select_autoescape

from src.entities.ais.iolib.colors import Colors
from src.lib.limited import Limited
from src.lib.toolkit import from_snake_case
from src.systems.acting.actions.inspect import Inspect
from src.systems.acting.actions.move import Move


class Panel:
    mode = Move

    def __init__(self, w, io):
        self._window = curses.newwin(1, 1, 0, 0)
        self.w = w
        self.io = io
        self.panes = [
            self._stats,
            self._controls,
        ]
        self.pane_i = Limited(len(self.panes), 0, 0)
        env = Environment(loader=PackageLoader(__name__), autoescape=select_autoescape())
        self.stats_template = env.get_template("stats.html")
        self.html_parser = PanelHtmlParser()

    def resize(self, h, w):
        self._window.resize(h - 1, self.w)
        self._window.mvwin(0, w - self.w)

    def render(self, subject, perception, level):
        h, w = self._window.getmaxyx()

        self._window.clear()
        self._window.border()

        self.panes[self.pane_i.current](subject, perception, level)

        if not self.pane_i.is_min():
            self._window.addstr(h - 2, 2, "<", Colors.Yellow.format())
            self._window.addstr(h - 2, 4, from_snake_case(self.panes[self.pane_i.current - 1].__name__).capitalize())

        if not self.pane_i.is_max():
            name = from_snake_case(self.panes[self.pane_i.current - 1].__name__).capitalize()
            self._window.addstr(h - 2, w - 3, ">", Colors.Yellow.format())
            self._window.addstr(h - 2, w - 4 - len(name), name)

        self._window.refresh()

    def _stats(self, subject, perception, level):
        inspected = "act" in subject and isinstance(subject.act, Inspect) and subject.act.subject or None
        html = self.stats_template.render(
            subject=subject,
            perception=perception,
            level=level,
            mode="MOVE" if self.mode == Move else "ATTACK",
            inspects=bool(inspected),
            looks_hurt=inspected and "health" in inspected and
            inspected.health.amount.current <= inspected.health.amount.maximum / 2,
        )

        self.html_parser.update(self._window, 1, 2)
        self.html_parser.feed(html.replace("\n", ""))

        # name_tag = f"\__ {subject.name} __/"
        #
        # self._window.addstr(1, 2, " " * ((self.w - 2 - len(name_tag)) // 2) + name_tag, curses.A_BOLD)
        # self._window.addstr(4, 2, f"Health: ")
        # self._window.addstr(4, 10,
        #     f"{subject.health.amount.current}/{subject.health.amount.maximum - 1}",
        #     Colors.Yellow.format()
        # )
        # self._window.addstr(5, 2, f"Armor: ")
        # self._window.addstr(5, 10, subject.health.armor_kind, Colors.Yellow.format())
        # self._window.addstr(6, 2, f"Damage: ")
        # self._window.addstr(6, 10, f"{subject.weapon.power} {subject.weapon.damage_kind}", Colors.Yellow.format())
        #
        # if self.mode == Move:
        #     self._window.addstr(8, 2, "MOVE")
        # else:
        #     self._window.addstr(8, 2, "ATTACK", Colors.WhiteOnRed.format())
        #
        # if "act" in subject and isinstance(subject.act, Inspect):
        #     inspected = subject.act.subject
        #
        #     self._window.addstr(10, 2, f"Inspects")
        #     self._window.addstr(10, 11, inspected.name, Colors.Yellow.format())
        #
        #     if "health" in inspected and inspected.health.amount.current <= inspected.health.amount.maximum / 2:
        #         self._window.addstr(11, 2, "Looks hurt", Colors.Yellow.format())

    def _controls(self, subject, perception, level):
        self._window.addstr(1, 2, "ACTION HOTKEYS")

        for i, (hotkey, f) in enumerate(self.io.action_hotkeys.items()):
            name = from_snake_case(f.__name__).capitalize()
            self._window.addstr(3 + i, 2, name)
            self._window.addstr(3 + i, 3 + len(name), hotkey, Colors.Yellow.format())

        start_y = 5 + len(self.io.action_hotkeys)
        self._window.addstr(start_y, 2, "OTHER HOTKEYS")

        for i, (hotkey, f) in enumerate(self.io.other_hotkeys.items()):
            if hotkey == "KEY_RESIZE": continue

            name = from_snake_case(f.__name__).capitalize()
            self._window.addstr(start_y + 2 + i, 2, name)
            self._window.addstr(start_y + 2 + i, 4 + len(name), hotkey, Colors.Yellow.format())


class PanelHtmlParser(HTMLParser):
    window = None
    y = None
    x = None
    padding_x = None
    color = Colors.Default
    centering = False

    def update(self, window, start_y, start_x):
        self.window = window
        self.start_y = start_y
        self.y = start_y
        self.x = start_x
        self.padding_x = start_x

    def handle_starttag(self, tag, attrs, **kwargs):
        match tag:
            case "center":
                self.centering = True
            case "b":
                self.color = Colors.Yellow

    def handle_endtag(self, tag):
        match tag:
            case "center":
                self.centering = False
            case "b":
                self.color = Colors.Default
            case "div" | "p":
                self.y += 1
                self.x = self.padding_x

    def handle_data(self, data):
        _, w = self.window.getmaxyx()

        if self.centering:
            self.x += (w - self.padding_x - len(data)) // 2

        data = data.lstrip(" ")
        if len(data) == 0: return

        logging.debug([self.y, self.x, data, self.color])
        self.window.addstr(self.y, self.x, data, self.color.format())
        self.x += len(data)
