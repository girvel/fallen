import curses

from ecs import create_system

from src.entities.special.screen import Colors
from src.lib.vector import Vector, zero
from src.systems.acting.move import Move

import logging

log = logging.getLogger(__name__)


@create_system
def resize_windows(screen: 'screen_flag'):
    h, w = screen.main.getmaxyx()
    screen.game.resize(h - 1, w - screen.gui_w)
    screen.following_offset = Vector(w - screen.gui_w, h - 1) // 3
    screen.gui.resize(h - 1, screen.gui_w)
    screen.gui.mvwin(0, w - screen.gui_w)

@create_system
def display_canvas(controller: 'controls', level: 'level_grid', screen: 'screen_flag'):
    screen.game.clear()

    h, w = screen.game.getmaxyx()
    for y in range(h):
        for x in range(w - 1):
            p_in_level = Vector(x + screen.virtual_p.x, y + screen.virtual_p.y)
            if zero <= p_in_level < level.size:
                entity = p_in_level.get_in(level.level_grid)
                view = [
                    entity and entity.character or ".",
                    get_color_pair(entity) | (
                        entity and entity == controller.controls.inspects and curses.A_REVERSE or 0
                    )
                ]
            else:
                view = [" "]

            screen.game.addch(y, x, *view)

    screen.game.refresh()

@create_system
def display_gui(controller: 'controls', screen: 'screen_flag'):
    screen.gui.clear()
    screen.gui.border()

    pc = controller.controls

    name_tag = f"\__ {pc.name} __/"

    screen.gui.addstr(1, 2, " " * ((screen.gui_w - 2 - len(name_tag)) // 2) + name_tag, curses.A_BOLD)
    screen.gui.addstr(4, 2, f"Health: ")
    screen.gui.addstr(4, 10, str(pc.health.value), Colors.Yellow.format())
    screen.gui.addstr(5, 2, f"Armor: ")
    screen.gui.addstr(5, 10, pc.health.armor_kind, Colors.Yellow.format())
    screen.gui.addstr(6, 2, f"Damage: ")
    screen.gui.addstr(6, 10, f"{pc.weapon.power} {pc.weapon.damage_kind}", Colors.Yellow.format())


    if controller.mode == Move:
        screen.gui.addstr(8, 2, "MOVE")
    else:
        screen.gui.addstr(8, 2, "ATTACK", Colors.WhiteOnRed.format())

    if pc.inspects:
        screen.gui.addstr(10, 2, f"Inspects {pc.inspects.name}")

    screen.gui.refresh()

display_systems = [
    resize_windows,
    # display_canvas,
    display_gui,
]
