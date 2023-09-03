import curses
from statistics import median

from src.entities.ais.iolib.colors import get_color_pair, Colors
from src.lib.vector import floordiv2, size2, safe_get2, sub2, le2, zero, lt2, add2
from src.systems.acting.actions.inspect import Inspect


class Game:
    virtual_p = (0, 0)
    following_offset = (0, 0)  # modified on resize

    layers_display_order = ["physical", "effects", "tiles"]

    def __init__(self, panel_w):
        self._window = curses.newwin(1, 1, 0, 0)
        self.panel_w = panel_w

    def resize(self, h, w):
        self._window.resize(h - 1, w - self.panel_w)
        self.following_offset = floordiv2((w - self.panel_w, h - 1), 3)

    def render(self, subject, perception, level):
        self._move_camera(subject, level)
        self._display_perception(subject, perception, level)

    def _move_camera(self, subject, level):
        screen_h, screen_w = self._window.getmaxyx()
        level_w, level_h = size2(level.grids.physical)

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

    def _display_perception(self, subject, perception, level):
        self._window.clear()
        h, w = self._window.getmaxyx()
        screen_size = (w - 1, h)

        for rx in range(0, screen_size[0]):
            for ry in range(0, screen_size[1]):
                character = safe_get2(subject.spacial_memory, add2((rx, ry), self.virtual_p))
                self._window.addch(ry, rx, character not in {None, "."} and character or " ")

        inspected = isinstance(subject.act, Inspect) and subject.act.subject
        for p in perception.vision.physical:
            rp = sub2(p, self.virtual_p)
            if not (le2(zero, rp) and lt2(rp, screen_size)): continue

            for layer in self.layers_display_order:
                if (entity := safe_get2(level.grids[layer], p)) is None: continue

                character = entity.character
                color = get_color_pair(entity) | (
                    inspected == entity
                        and curses.A_REVERSE
                        or 0
                )
                break
            else:
                character = "."
                color = Colors.Default.format()

            self._window.addch(rp[1], rp[0], character, color)

        self._window.refresh()