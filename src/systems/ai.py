import random
from enum import Enum
from math import copysign

from ecs import create_system

from src.lib.toolkit import sign
from src.lib.vector import Vector, one
from src.systems.acting.attack import Attack
from src.systems.acting.move import Move


class Kind(Enum):
    Animate = 0

@create_system
def attack_if_possible(subject: 'choose_target', level: 'level_grid'):
    start = subject.p - subject.vision * one
    end = subject.p + subject.vision * one

    possible_targets = []

    for y in range(start.y, end.y + 1):
        for x in range(start.x, end.x + 1):
            e = level.level_grid[y][x]

            if e:
                possible_targets.append(e)

    target = subject.choose_target(possible_targets)
    if not target: return

    v = target.p - subject.p
    if v.is_minimal():
        subject.act = Attack(v)
    else:
        if v.x * v.y == 0:
            subject.act = Move(v.integer_normalize())
        else:
            v1 = Vector(sign(v.x), 0)
            v2 = Vector(0, sign(v.y))

            if (subject.p + v1).get_in(level.level_grid) is not None:
                subject.act = Move(v1)
            elif (subject.p + v2).get_in(level.level_grid) is not None:
                subject.act = Move(v2)
            else:
                subject.act = Move(random.choice([v1, v2]))
