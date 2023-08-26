from dataclasses import dataclass
from enum import Enum

import numba as numba
import numpy
from ecs import create_system, OwnedEntity
from line_profiler import profile

from src.lib.vector import Vector, up, down, left, right, one

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
    vision: dict[Vector, OwnedEntity]
    hearing: dict[Vector, int]
    smell: dict[Vector, OwnedEntity]


@numba.njit(parallel=True)
def project_rays(vision, x, y, power, w, h):
    if x < 0 or y < 0 or x >= w or y >= h:
        return

    value = vision[x, y]
    if value >= power:
        return

    if value == -1:
        vision[x, y] = 1000
        return

    vision[x, y] = power

    power -= 1

    dx = x - w // 2
    dy = y - h // 2

    if dy <= -abs(dx):
        project_rays(vision, x, y - 1, power, w, h)
        project_rays(vision, x - 1, y, power, w, h)
        project_rays(vision, x + 1, y, power, w, h)
    elif dx >= abs(dy):
        project_rays(vision, x, y - 1, power, w, h)
        project_rays(vision, x, y + 1, power, w, h)
        project_rays(vision, x + 1, y, power, w, h)
    elif dy >= abs(dx):
        project_rays(vision, x, y + 1, power, w, h)
        project_rays(vision, x - 1, y, power, w, h)
        project_rays(vision, x + 1, y, power, w, h)
    else:
        project_rays(vision, x, y - 1, power, w, h)
        project_rays(vision, x, y + 1, power, w, h)
        project_rays(vision, x - 1, y, power, w, h)

@profile
def calculate_vision(level_grid, start, r):
    size = one * (2 * r + 1)
    edge = start - one * r
    vision = numpy.full((size.x, size.y), 0)

    for vy in range(0, size.y):
        for vx in range(0, size.x):
            entity = (edge + Vector(vx, vy)).get_in(level_grid)
            if entity and "solid_flag" in entity:
                vision[vx, vy] = -1

    vision[r][r] = 0
    project_rays(vision, r, r, r + 1, size.x, size.y)
    return {
        p: p.get_in(level_grid)
        for (x, y), v in numpy.ndenumerate(vision)
        if v > 0 and (p := Vector(x, y) + edge)
    }

@create_system
def think(subject: 'ai', level: 'level_grid'):
    subject.act = subject.ai.make_decision(
        subject,
        "senses" in subject
            and Perception(calculate_vision(level.level_grid, subject.p, subject.senses.vision), None, None)
            or Perception(None, None, None),
    )

    # start = subject.p - subject.vision * one
    # end = subject.p + subject.vision * one
    #
    # possible_targets = []
    #
    # for y in range(start.y, end.y + 1):
    #     for x in range(start.x, end.x + 1):
    #         e = level.level_grid[y][x]
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
    #         if (subject.p + v1).get_in(level.level_grid) is not None:
    #             subject.act = Move(v2)
    #         elif (subject.p + v2).get_in(level.level_grid) is not None:
    #             subject.act = Move(v1)
    #         else:
    #             subject.act = Move(random.choice([v1, v2]))
