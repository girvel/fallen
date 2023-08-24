from collections import namedtuple

from ecs import create_system

from src.lib.vector import zero


class Act:
    Move = namedtuple("Move", "v")
    Attack = namedtuple("Attack", "v")


@create_system
def act(movable: 'p, act', level: 'level_grid', hades: 'entities_to_destroy'):
    next_p = movable.p + movable.act.v
    if not (next_p >= zero) or not (next_p < level.size):
        movable.v = zero
        return

    if next_p.get_in(level.level_grid) is not None:
        if isinstance(movable.act, Act.Attack):
            enemy = next_p.get_in(level.level_grid)

            if "health" in enemy:
                enemy.health -= movable.power
                if enemy.health <= 0:
                    hades.entities_to_destroy.append(enemy)
        else:
            movable.v = zero
    else:
        movable.p.set_in(level.level_grid, None)
        level.put(movable, next_p)
