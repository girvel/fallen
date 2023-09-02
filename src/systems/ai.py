from dataclasses import dataclass
from enum import Enum

import numba as numba
import numpy
from ecs import create_system, OwnedEntity

from src.lib.vector import sub2, add2, safe_get2, unsafe_set2

import logging

log = logging.getLogger(__name__)


class Kind(Enum):
    Animate = 0
    Table = 1

def classified_as(entity, kind):
    return "classifiers" in entity and kind in entity.classifiers

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
    free_cache: numpy.ndarray


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

def calculate_vision(physical_grid, p, r):
    d = 2 * r + 1
    array, (level_w, level_h) = physical_grid

    edge = (p[0] - r, p[1] - r)
    vision = numpy.full((d, d), 0)  # TODO crop it to not intersect level borders

    for y in range(max(edge[1], 0), min(edge[1] + d, level_h)):  # TODO diamond-shape iteration
        for x in range(max(edge[0], 0), min(edge[0] + d, level_w)):
            entity = array[y][x]
            if entity is not None and "solid_flag" in entity:
                vision[sub2((x, y), edge)] = -1

    free_cache = vision + 1

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

    return result, free_cache

def calculate_smell(physical_grid, p, r):
    result = {}

    for dy in range(-r, r + 1):  # TODO optimize for level borders
        for dx in range(abs(dy) - r, r - abs(dy) + 1):
            p = add2(p, (dx, dy))
            if (entity := safe_get2(physical_grid, p)) is not None:
                result[p] = entity

    return result

@create_system
def think(subject: 'ai', level: 'physical_grid'):
    vision, free_cache = (subject.senses.vision > 0
        and calculate_vision(level.physical_grid, subject.p, subject.senses.vision)
        or (None, None)
    )

    if vision is not None:
        for p, entity in vision.items():
            unsafe_set2(subject.spacial_memory, p, entity is not None and entity.character or ".")

    subject.act = subject.ai.make_decision(subject, Perception(
        vision,
        None,
        subject.senses.smell > 0 and calculate_smell(level.physical_grid, subject.p, subject.senses.smell),
        free_cache
    ))
