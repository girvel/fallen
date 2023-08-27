from dataclasses import dataclass
from enum import Enum

import numba as numba
import numpy
from ecs import create_system, OwnedEntity

from src.lib.vector import sub2

import logging

log = logging.getLogger(__name__)


class Kind(Enum):
    Animate = 0

@dataclass
class Senses:
    vision: int
    hearing: int
    smell: int

@dataclass
class Perception:
    vision: dict[tuple[int, int], OwnedEntity]
    hearing: dict[tuple[int, int], int]
    smell: dict[tuple[int, int], OwnedEntity]


@numba.njit
def project_rays(vision, x, y, power, cx, cy):
    value = vision[x, y]
    if value >= power:
        return

    if value == -1:
        vision[x, y] = 1000
        return

    vision[x, y] = power

    power -= 1
    if power == 0: return

    dx = x - cx
    dy = y - cy

    if dy <= -abs(dx):
        dirs = (
            (x, y - 1),
            (x - 1, y),
            (x + 1, y),
        )
    elif dx >= abs(dy):
        dirs = (
            (x, y - 1),
            (x, y + 1),
            (x + 1, y),
        )
    elif dy >= abs(dx):
        dirs = (
            (x, y + 1),
            (x - 1, y),
            (x + 1, y),
        )
    else:
        dirs = (
            (x, y - 1),
            (x, y + 1),
            (x - 1, y),
        )

    for i in range(3):
        d = dirs[i]
        project_rays(vision, d[0], d[1], power, cx, cy)

def calculate_vision(physical_grid, start, r):
    d = 2 * r + 1
    array, (level_w, level_h) = physical_grid

    edge = (start[0] - r, start[1] - r)
    vision = numpy.full((d, d), 0)  # TODO crop it to not intersect level borders

    for y in range(max(edge[1], 0), min(edge[1] + d, level_h)):
        for x in range(max(edge[0], 0), min(edge[0] + d, level_w)):
            entity = array[y][x]
            if entity is not None and "solid_flag" in entity:
                vision[sub2((x, y), edge)] = -1

    vision[r][r] = r + 1
    project_rays(vision, r + 1, r, r, r, r)
    project_rays(vision, r - 1, r, r, r, r)
    project_rays(vision, r, r + 1, r, r, r)
    project_rays(vision, r, r - 1, r, r, r)

    result = {}
    for y in range(max(edge[1], 0), min(edge[1] + d, level_h)):
        for x in range(max(edge[0], 0), min(edge[0] + d, level_w)):
            if vision[x - edge[0], y - edge[1]] <= 0: continue
            result[x, y] = array[y][x]

    return result

@create_system
def think(subject: 'ai', level: 'physical_grid'):
    subject.act = subject.ai.make_decision(
        subject,
        "senses" in subject
            and Perception(calculate_vision(level.physical_grid, subject.p, subject.senses.vision), None, None)
            or Perception(None, None, None),
    )

    # start = subject.p - subject.vision * one
    # end = subject.p + subject.vision * one
    #
    # possible_targets = []
    #
    # for y in range(start.y, end.y + 1):
    #     for x in range(start.x, end.x + 1):
    #         e = level.physical_grid[y][x]
    #
    #         if e:
    #             possible_targets.append(e)
    #
    # target = subject.choose_target(possible_targets)
    # if not target: return
    #
    # v = target.p - subject.p
    # if v.is_minimal():
    #     subject.act = Attack(v)
    # else:
    #     if v.x * v.y == 0:
    #         subject.act = Move(v.integer_normalize())
    #     else:
    #         v1 = Vector(sign(v.x), 0)
    #         v2 = Vector(0, sign(v.y))
    #
    #         if (subject.p + v1).get_in(level.physical_grid) is not None:
    #             subject.act = Move(v2)
    #         elif (subject.p + v2).get_in(level.physical_grid) is not None:
    #             subject.act = Move(v1)
    #         else:
    #             subject.act = Move(random.choice([v1, v2]))
