from dataclasses import dataclass
from enum import Enum

import numba as numba
import numpy
import tcod.map
from ecs import create_system, OwnedEntity, Entity
from line_profiler import profile

from src.lib.vector import sub2, add2, grid_get, grid_set

import logging



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
    vision: Entity
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

def calculate_vision(grids, p, r):
    d = 2 * r + 1
    array, (level_w, level_h) = grids.physical

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

    result = Entity(**{l: {} for l, _ in grids})
    for y in range(max(edge[1], 0), min(edge[1] + d, level_h)):
        for x in range(max(edge[0], 0), min(edge[0] + d, level_w)):
            if vision[x - edge[0], y - edge[1]] <= 0: continue

            for l, grid in grids:
                result[l][x, y] = grid[0][y][x]

    return result, free_cache

@profile
def calculate_vision_tcod(grids, transparency, p, r):
    d = 2 * r + 1
    array, (level_w, level_h) = grids.physical

    edge = (p[0] - r, p[1] - r)
    fov = tcod.map.compute_fov(transparency, p, r)

    result = Entity(**{l: {} for l, _ in grids})
    for y in range(max(edge[1], 0), min(edge[1] + d, level_h)):
        for x in range(max(edge[0], 0), min(edge[0] + d, level_w)):
            if not fov[x, y]: continue

            for l, grid in grids:
                result[l][x, y] = grid[0][y][x]

    return result, transparency

def calculate_smell(physical_grid, p, r):
    result = {}

    for dy in range(-r, r + 1):  # TODO optimize for level borders
        for dx in range(abs(dy) - r, r - abs(dy) + 1):
            smell_p = add2(p, (dx, dy))
            if (entity := grid_get(physical_grid, smell_p)) is not None:
                result[smell_p] = entity

    return result


@create_system
def update_transparency_cache(cache: 'transparency_array', level: 'grids'):
    for y, line in enumerate(level.grids.physical[0]):
        for x, e in enumerate(line):
            cache.transparency_array[x, y] = int(e is None or not hasattr(e, "solid_flag"))


@create_system
def run_rails(rails: 'rails_flag', level: 'grids', hades: 'entities_to_destroy'):
    for effect in rails.run():
        level.rails_effect = effect or {}
        logging.debug(level.rails_effect)
        yield

    hades.entities_to_destroy.add(rails)
    level.rails_effect = {}


@create_system
def think(subject: 'ai', level: 'grids', cache: 'transparency_array'):
    if subject in level.rails_effect:
        subject.act = level.rails_effect[subject]
        return

    vision, free_cache = (subject.senses.vision > 0
        and calculate_vision_tcod(level.grids, cache.transparency_array, subject.p, subject.senses.vision)
        or (None, None)
    )

    if vision is not None:
        for p, entity in vision.physical.items():
            grid_set(subject.spacial_memory, p, entity is not None and entity.character or ".")

    subject.act = subject.ai.make_decision(subject, Perception(
        vision,
        subject.senses.hearing > 0 and calculate_smell(level.grids.sounds, subject.p, subject.senses.hearing),
        subject.senses.smell > 0 and calculate_smell(level.grids.physical, subject.p, subject.senses.smell),
        free_cache
    ))

sequence = [
    update_transparency_cache,
    run_rails,
    think,
]
