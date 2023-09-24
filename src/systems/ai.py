import logging
from dataclasses import dataclass
from enum import Enum
from typing import Any, TypeVar

import numpy
import tcod.map
from ecs import create_system, OwnedEntity, Entity
from line_profiler import profile
from numpy import ndarray, dtype

from src.entities.special.sound import Sound
from src.lib.query import Query
from src.lib.vector import add2, grid_get, grid_set, int2, fits_in_grid, grid_unsafe_get, grid_size


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
    hearing: {int2: Sound}
    smell: {int2: OwnedEntity}

@dataclass
class GridProxy:
    _grid: tuple[list[list[OwnedEntity]], int2]
    _avaliability_mask: ndarray[Any, dtype[bool]]

    T = TypeVar('T')
    def get(self, key: int2, default: T = None) -> OwnedEntity | T:
        if not fits_in_grid(self._grid, key) or not self._avaliability_mask[key]:
            return default

        return grid_unsafe_get(self._grid, key)

    def values(self):
        return (
            e
            for y, row in enumerate(self._grid[0])
            for x, e in enumerate(row)
            if self._avaliability_mask[x, y]
        )

    def items(self):
        return (
            ((x, y), e)
            for y, row in enumerate(self._grid[0])
            for x, e in enumerate(row)
            if self._avaliability_mask[x, y]
        )

    def __iter__(self):
        return (
            (x, y)
            for y, row in enumerate(self._grid[0])
            for x, e in enumerate(row)
            if self._avaliability_mask[x, y]
        )

    def __contains__(self, item: int2) -> bool:
        return fits_in_grid(self._grid, item) and self._avaliability_mask[item]

@profile
def calculate_vision(grids, transparency, p, r):
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

    return result

def calculate_smell(grid, p, r):
    result = {}

    for dy in range(-r, r + 1):  # TODO optimize for level borders
        for dx in range(abs(dy) - r, r - abs(dy) + 1):
            smell_p = add2(p, (dx, dy))
            if (entity := grid_get(grid, smell_p)) is not None:
                result[smell_p] = entity

    return result


def create_square_rhombus(radius, position, field_size):
    return numpy.fromfunction(
        lambda x, y: abs(x - position[0]) + abs(y - position[1]) <= radius,
        field_size
    )


@create_system
def update_transparency_cache(cache: 'transparency_array', level: 'grids'):
    for y, line in enumerate(level.grids.physical[0]):
        for x, e in enumerate(line):
            cache.transparency_array[x, y] = int(e is None or not hasattr(e, "solid_flag"))


@create_system
def run_rails(rails: 'rails_flag', level: 'grids', hades: 'entities_to_destroy'):
    current_scene = next((s for s in rails.scenes if s.enabled and s.start_predicate()), None)
    if current_scene is None: return

    logging.info(f"Starting the scene '{current_scene.name}'")
    for effect in current_scene.run():
        level.rails_effect = effect or {}
        yield

    level.rails_effect = {}
    logging.info(f"Finished the scene '{current_scene.name}'")


@create_system
def think(subject: 'ai', level: 'grids', cache: 'transparency_array'):
    is_railed = subject in level.rails_effect

    if is_railed:
        subject.act = level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if subject.senses.vision > 0:
        fov = tcod.map.compute_fov(cache.transparency_array, subject.p, subject.senses.vision)
        vision = Entity(**{layer: GridProxy(grid, fov) for layer, grid in level.grids})

        for p, entity in vision.physical.items():
            grid_set(subject.spacial_memory, p, entity is not None and entity.character or ".")
    else:
        vision = None

    act = subject.ai.make_decision(subject, Perception(
        vision,
        subject.senses.hearing > 0 and GridProxy(level.grids.sounds, create_square_rhombus(
            subject.senses.hearing, subject.p, grid_size(level.grids.sounds)
        )),
        subject.senses.smell > 0 and GridProxy(level.grids.physical, create_square_rhombus(
            subject.senses.hearing, subject.p, grid_size(level.grids.smell)
        )),
    ))

    if not is_railed:
        subject.act = act


sequence = [
    update_transparency_cache,
    run_rails,
    think,
]
