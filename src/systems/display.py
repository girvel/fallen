import curses

from ecs import create_system

from src.entities.special.screen import Colors


def _get_color_pair(entity):
    if entity is None:
        return Colors.Default

    if getattr(entity, "receives_damage", None):
        return Colors.Red

    return getattr(entity, "color", Colors.Default)

def get_color_pair(entity):
    return curses.color_pair(_get_color_pair(entity).value)


@create_system
def display_canvas(level: 'level_grid', screen: 'screen_flag'):
    screen.main.clear()

    h, w = screen.main.getmaxyx()
    for y in range(min(h, level.size.y)):
        for x in range(min(w, level.size.x)):
            entity = level.level_grid[y][x]

            screen.main.addch(y, x, entity and entity.character or ".", get_color_pair(entity))

    screen.main.refresh()