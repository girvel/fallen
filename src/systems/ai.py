import logging
from dataclasses import dataclass
from enum import Enum
from typing import Any, TypeVar

import numpy
import tcod.map
from ecs import create_system, DynamicEntity, Entity
from numpy import ndarray, dtype

from src.entities.special.sound import Sound
from src.lib.vector import grid_set, int2, fits_in_grid, grid_unsafe_get


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
    smell: {int2: DynamicEntity}

@dataclass
class GridProxy:
    _grid: tuple[list[list[DynamicEntity]], int2]
    _avaliability_mask: ndarray[Any, dtype[bool]]
    _start: int2
    _end: int2

    T = TypeVar('T')
    def get(self, key: int2, default: T = None) -> DynamicEntity | T:
        if not fits_in_grid(self._grid, key) or not self._avaliability_mask[key]:
            return default

        return grid_unsafe_get(self._grid, key)

    def values(self):
        return (
            grid_unsafe_get(self._grid, (x, y))
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._avaliability_mask[x, y]
        )

    def items(self):
        return (
            ((x, y), grid_unsafe_get(self._grid, (x, y)))
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._avaliability_mask[x, y]
        )

    def __iter__(self):
        return (
            (x, y)
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._avaliability_mask[x, y]
        )

    def __contains__(self, item: int2) -> bool:
        return fits_in_grid(self._grid, item) and self._avaliability_mask[item]


def create_square_rhombus(position, radius, field_size):
    return numpy.fromfunction(
        lambda x, y: abs(x - position[0]) + abs(y - position[1]) <= radius,
        field_size
    )


def borders_from_radius(p: int2, r: int, size: int2) -> tuple[int2, int2]:
    return (
        (max(0, p[0] - r), max(0, p[1] - r)),
        (min(size[0], p[0] + r + 1), min(size[1], p[1] + r + 1)),
    )


@create_system
def update_transparency_cache(level: 'grids'):
    for y, line in enumerate(level.grids.physical[0]):
        for x, e in enumerate(line):
            level.transparency_cache[x, y] = int(e is None or not hasattr(e, "solid_flag"))


@create_system
def run_rails(level: 'grids', hades: 'entities_to_destroy'):
    if level.rails is None: return

    level.rails.current_scene = next((s for s in level.rails.scenes if s.enabled and s.start_predicate()), None)
    if level.rails.current_scene is None: return

    logging.info(f"Starting the scene '{level.rails.current_scene.name}'")
    for effect in level.rails.current_scene.run():
        level.rails_effect = effect or {}
        yield

    level.rails_effect = {}
    logging.info(f"Finished the scene '{level.rails.current_scene.name}'")


@create_system
def think(subject: 'ai'):
    is_railed = subject in subject.level.rails_effect

    if is_railed:
        subject.act = subject.level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if (r := subject.senses.vision) > 0:
        fov = tcod.map.compute_fov(subject.level.transparency_cache, subject.p, r)
        vision = Entity(**{
            layer: GridProxy(
                grid, fov,
                *borders_from_radius(subject.p, r, subject.level.size)
            )
            for layer, grid in subject.level.grids
        })

        for p, entity in vision.physical.items():
            grid_set(subject.spacial_memory, p, entity is not None and entity.character or ".")
    else:
        vision = None

    act = subject.ai.make_decision(subject, Perception(
        vision,
        (r := subject.senses.hearing) > 0 and GridProxy(
            subject.level.grids.sounds,
            create_square_rhombus(subject.p, r, subject.level.size),
            *borders_from_radius(subject.p, r, subject.level.size),
        ),
        (r := subject.senses.smell) > 0 and GridProxy(
            subject.level.grids.physical,
            create_square_rhombus(subject.p, r, subject.level.size),
            *borders_from_radius(subject.p, r, subject.level.size),
        ),
    ))

    if not is_railed:
        subject.act = act


sequence = [
    update_transparency_cache,
    run_rails,
    think,
]
