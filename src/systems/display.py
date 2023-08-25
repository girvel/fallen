import curses

from ecs import create_system

from src.entities.special.screen import Colors
from src.systems.acting.move import Move


def _get_color_pair(entity):
    if entity is None:
        return Colors.Default

    if getattr(entity, "receives_damage", None):
        return Colors.Red

    return getattr(entity, "color", Colors.Default)

def get_color_pair(entity):
    return curses.color_pair(_get_color_pair(entity).value)


@create_system
def resize_windows(screen: 'screen_flag'):
    h, w = screen.main.getmaxyx()
    screen.game.resize(h - 1, w - screen.gui_w)
    screen.gui.mvwin(0, w - screen.gui_w)
    screen.gui.resize(h - 1, screen.gui_w)

@create_system
def display_canvas(controller: 'controls', level: 'level_grid', screen: 'screen_flag'):
    screen.game.clear()

    h, w = screen.game.getmaxyx()
    for y in range(min(h, level.size.y)):
        for x in range(min(w, level.size.x)):
            entity = level.level_grid[y][x]

            screen.game.addch(
                y, x, entity and entity.character or ".",
                get_color_pair(entity) | (entity and entity == controller.controls.inspects and curses.A_REVERSE or 0)
            )

    screen.game.refresh()

@create_system
def display_gui(controller: 'controls', screen: 'screen_flag'):
    screen.gui.clear()
    screen.gui.border()

    pc = controller.controls

    screen.gui.addstr(2, 2, pc.name)
    screen.gui.addstr(3, 2, f"Health: {pc.health}")
    screen.gui.addstr(4, 2, f"Attack power: {pc.power}")

    if controller.mode == Move:
        screen.gui.addstr(6, 2, "MOVE")
    else:
        screen.gui.addstr(6, 2, "ATTACK", curses.color_pair(Colors.WhiteOnRed.value))

    if pc.inspects:
        screen.gui.addstr(8, 2, f"Inspects {pc.inspects.name}")

    screen.gui.refresh()

display_systems = [
    resize_windows,
    display_canvas,
    display_gui,
]
