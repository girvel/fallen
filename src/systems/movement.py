from ecs import create_system

from src.lib.vector import zero


@create_system
def move(movable: 'p, v', level: 'level_grid'):
    next_p = movable.p + movable.v
    if not (next_p >= zero) or not (next_p < level.size) or next_p.get_in(level.level_grid) is not None:
        movable.v = zero
        return

    movable.p.set_in(level.level_grid, None)
    level.put(movable, next_p)