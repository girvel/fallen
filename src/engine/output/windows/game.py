import curses
from statistics import median

from src.engine.acting.actions.inspect import Inspect
from src.engine.output.colors import ColorPair, red
from src.engine.output.window import Window
from src.entities.special.level import Level
from src.lib.query import Q
from src.lib.vector import floordiv2, grid_get, sub2, le2, zero, lt2, add2


class Game(Window):
    virtual_p = (0, 0)
    layers_display_order = ["physical", "effects", "tiles"]

    def _responsive_size(self, subject, perception, max_size):
        return sub2(
            max_size,
            (0, 1) if self.io.memory.in_cutscene else
            (self.io.output.panel.border_curses_window.getmaxyx()[1], 1)
        )

    def _render(self, subject, perception):
        self._move_camera(subject)
        self._display_perception(subject, perception)

    def _move_camera(self, subject):
        h, w = self.curses_window.getmaxyx()
        w -= 1  # display area width is 1 character smaller

        following_offset = floordiv2((w, h), 3)

        self.virtual_p = (
            median((
                0,
                subject.p[0] - w + following_offset[0],
                self.virtual_p[0],
                subject.p[0] - following_offset[0],
                subject.level.size[0] - w,
            )),
            median((
                0,
                subject.p[1] - h + following_offset[1],
                self.virtual_p[1],
                subject.p[1] - following_offset[1],
                subject.level.size[1] - h,
            ))
        )

    def _display_perception(self, subject, perception):
        self.curses_window.clear()
        h, w = self.curses_window.getmaxyx()
        screen_size = (w - 1, h)

        spacial_memory = self.io.memory.spacial_memory[subject.level]
        for rx in range(0, screen_size[0]):
            for ry in range(0, screen_size[1]):
                character = grid_get(spacial_memory, add2((rx, ry), self.virtual_p))
                self.curses_window.addch(ry, rx, character not in {None, Level.no_entity_character} and character or " ")

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
                    if self.io.memory.current_sound is not None
                    and not self.io.memory.current_sound.is_internal
                    and self.io.memory.current_sound is perception.hearing.get(p)
                    else 0
                )
                break
            else:
                character = Level.no_entity_character
                color = ColorPair().to_curses()

            self.curses_window.addch(rp[1], rp[0], character, color)

        self.curses_window.refresh()


def _get_color_pair(entity):
    if entity is None:
        return ColorPair()

    if ~Q(entity).health.last_damaged_by.Q_len() not in (None, 0):
        return ColorPair(red)

    return getattr(entity, "color", ColorPair())


def get_color_pair(entity):  # TODO refactor
    color = _get_color_pair(entity).to_curses()

    if entity.layer in {"physical", "effects"}:
        color |= curses.A_BOLD

    return color
