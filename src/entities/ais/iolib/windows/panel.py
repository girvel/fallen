import curses

from src.entities.ais.iolib.colors import Colors
from src.systems.acting.actions.inspect import Inspect
from src.systems.acting.actions.move import Move


class Panel:
    mode = Move

    def __init__(self, w):
        self._window = curses.newwin(1, 1, 0, 0)
        self.w = w

    def resize(self, h, w):
        self._window.resize(h - 1, self.w)
        self._window.mvwin(0, w - self.w)

    def render(self, subject, perception, level):
        self._window.clear()
        self._window.border()

        name_tag = f"\__ {subject.name} __/"

        self._window.addstr(1, 2, " " * ((self.w - 2 - len(name_tag)) // 2) + name_tag, curses.A_BOLD)
        self._window.addstr(4, 2, f"Health: ")
        self._window.addstr(4, 10,
            f"{subject.health.amount.current}/{subject.health.amount.maximum}",
            Colors.Yellow.format()
        )
        self._window.addstr(5, 2, f"Armor: ")
        self._window.addstr(5, 10, subject.health.armor_kind, Colors.Yellow.format())
        self._window.addstr(6, 2, f"Damage: ")
        self._window.addstr(6, 10, f"{subject.weapon.power} {subject.weapon.damage_kind}", Colors.Yellow.format())

        if self.mode == Move:
            self._window.addstr(8, 2, "MOVE")
        else:
            self._window.addstr(8, 2, "ATTACK", Colors.WhiteOnRed.format())

        if "act" in subject and isinstance(subject.act, Inspect):
            inspected = subject.act.subject

            self._window.addstr(10, 2, f"Inspects")
            self._window.addstr(10, 11, inspected.name, Colors.Yellow.format())

            if "health" in inspected and inspected.health.amount.current <= inspected.health.amount.maximum / 2:
                self._window.addstr(11, 2, "Looks hurt", Colors.Yellow.format())

        self._window.refresh()
