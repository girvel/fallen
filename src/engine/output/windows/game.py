import curses
from statistics import median

from src.engine.ai import Perception
from src.engine.output.colors import ColorPair, red, black
from src.engine.output.window import Window
from src.lib.query import Q
from src.lib.vector.grid import grid_unsafe_get
from src.lib.vector.vector import floordiv2, sub2, add2
from src.library.special.level import Level


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

    def _display_perception(self, subject, perception: Perception):
        # questionably optimized

        self.curses_window.clear()
        h, w = self.curses_window.getmaxyx()
        screen_size = (w - 1, h)

        spacial_memory = self.io.memory.spacial_memory[subject.level]
        proxy_sample = perception.vision["physical"]

        rx_perception_zone_start = proxy_sample._center[0] - proxy_sample._r - self.virtual_p[0]
        rx_perception_zone_end = proxy_sample._center[0] + proxy_sample._r - self.virtual_p[0]

        ry_perception_zone_start = proxy_sample._center[1] - proxy_sample._r - self.virtual_p[1]
        ry_perception_zone_end = proxy_sample._center[1] + proxy_sample._r - self.virtual_p[1]

        rx_range = range(
            max(0, -self.virtual_p[0]),
            min(screen_size[0], subject.level.size[0] - self.virtual_p[0])
        )
        ry_range = range(
            max(0, -self.virtual_p[1]),
            min(screen_size[1], subject.level.size[1] - self.virtual_p[1])
        )

        for rx in rx_range:
            can_x_be_in_perception = rx_perception_zone_start <= rx <= rx_perception_zone_end

            for ry in ry_range:
                can_y_be_in_perception = ry_perception_zone_start <= ry <= ry_perception_zone_end

                p = add2((rx, ry), self.virtual_p)

                if (
                    not can_x_be_in_perception or
                    not can_y_be_in_perception or
                    not proxy_sample.unsafe_contains(p)
                ):
                    character = grid_unsafe_get(spacial_memory, p)
                    self.curses_window.addch(
                        ry, rx, character not in (None, Level.no_entity_character) and character or " "
                    )
                    continue

                for layer in self.layers_display_order:
                    if (entity := grid_unsafe_get(subject.level.grids[layer], p)) is None: continue

                    if ~Q(entity).health.last_damaged_by.Q_len() not in (None, 0):
                        color = ColorPair(red)
                    else:
                        color = getattr(entity, "color", ColorPair())

                    is_fully_black = color == ColorPair(black, black)
                    curses_color = color.to_curses()

                    if (
                        layer in ("physical", "effects") and color.fg != black
                        if not hasattr(entity, "is_blinking") else entity.is_blinking
                    ):
                        curses_color |= curses.A_BOLD

                    if self.io.memory.inspect_target == entity:
                        curses_color |= curses.A_REVERSE

                    if (
                        (sound := self.io.memory.current_sound) is not None
                        and not sound.is_internal
                        and sound is perception.hearing.get(p)
                    ):
                        curses_color |= curses.A_BLINK

                    character = entity.character if not is_fully_black else " "
                    self.curses_window.addch(ry, rx, character, curses_color)
                    break
                else:
                    self.curses_window.addch(ry, rx, Level.no_entity_character)

        self.curses_window.refresh()
