import curses
from statistics import median

from src.engine.acting.actions.inspect import Inspect
from src.engine.output.colors import ColorPair, red
from src.lib.vector import floordiv2, grid_get, sub2, le2, zero, lt2, add2


class Game:
    virtual_p = (0, 0)
    following_offset = (0, 0)  # modified on resize

    layers_display_order = ["physical", "effects", "tiles"]

    def __init__(self, panel_w):
        self._window = curses.newwin(1, 1, 0, 0)
        self.panel_w = panel_w
        self.last_parent_h = None
        self.last_parent_w = None

    def resize(self, h, w):
        self.last_parent_h = h
        self.last_parent_w = w

    def _responsive_resize(self, memory):
        h = self.last_parent_h
        w = self.last_parent_w

        if memory.in_cutscene:
            self._window.resize(h - 1, w)
            self.following_offset = floordiv2((w, h - 1), 3)
        else:
            self._window.resize(h - 1, w - self.panel_w)
            self.following_offset = floordiv2((w - self.panel_w, h - 1), 3)

    def render(self, subject, perception, memory):
        self._responsive_resize(memory)
        self._move_camera(subject)
        self._display_perception(subject, perception, memory)

    def _move_camera(self, subject):
        screen_h, screen_w = self._window.getmaxyx()

        self.virtual_p = (
            median((
                0,
                subject.p[0] - screen_w + self.following_offset[0],
                self.virtual_p[0],
                subject.p[0] - self.following_offset[0],
                subject.level.size[0] - screen_w,
            )),
            median((
                0,
                subject.p[1] - screen_h + self.following_offset[1],
                self.virtual_p[1],
                subject.p[1] - self.following_offset[1],
                subject.level.size[1] - screen_h,
            ))
        )

    def _display_perception(self, subject, perception, memory):
        self._window.clear()
        h, w = self._window.getmaxyx()
        screen_size = (w - 1, h)

        spacial_memory = memory.spacial_memory[subject.level]
        for rx in range(0, screen_size[0]):
            for ry in range(0, screen_size[1]):
                character = grid_get(spacial_memory, add2((rx, ry), self.virtual_p))
                self._window.addch(ry, rx, character not in {None, "."} and character or " ")

        inspected = isinstance(subject.act, Inspect) and subject.act.subject
        for p in perception.vision.physical:
            rp = sub2(p, self.virtual_p)
            if not (le2(zero, rp) and lt2(rp, screen_size)): continue

            for layer in self.layers_display_order:
                if (entity := grid_get(subject.level.grids[layer], p)) is None: continue

                character = entity.character
                color = get_color_pair(entity) | (
                    inspected == entity
                        and curses.A_REVERSE
                        or 0
                ) | (
                    curses.A_BLINK
                    if memory.current_sound is not None and memory.current_sound is perception.hearing.get(p)
                    else 0
                )
                break
            else:
                character = "."
                color = ColorPair().to_curses()

            self._window.addch(rp[1], rp[0], character, color)

        self._window.refresh()


def _get_color_pair(entity):
    if entity is None:
        return ColorPair()

    if getattr(entity, "receives_damage", None):
        return ColorPair(red)

    return getattr(entity, "color", ColorPair())


def get_color_pair(entity):  # TODO refactor
    color = _get_color_pair(entity).to_curses()

    if entity.layer in {"physical", "effects"}:
        color |= curses.A_BOLD

    return color
