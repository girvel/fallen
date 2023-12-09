from collections.abc import Iterator
from dataclasses import dataclass
from enum import Enum
from typing import Any, TypeVar, Generic

import numpy
from numpy import ndarray, dtype

from src.components import Positioned
from src.lib.vector.vector import int2
from src.lib.vector.grid import fits_in_grid, grid_unsafe_get, grid_size
from src.library.special.sound import Sound


class Kind(Enum):
    Animate = 0
    Table = 1


def classified_as(entity, kind):
    return hasattr(entity, "classifiers") and kind in entity.classifiers


@dataclass
class Senses:
    vision: int
    hearing: int
    smell: int


T = TypeVar('T', bound=Positioned)
R = TypeVar('R')
Grid = tuple[list[list[T | None]], int2]

@dataclass(init=False)
class GridProxy(Generic[T]):
    _grid: Grid
    _availability_mask: ndarray[Any, dtype[bool]]
    _start: int2
    _end: int2

    def __init__(self, grid: Grid, p: int2, r: int2, mask: ndarray[Any, dtype[bool]] | None = None):
        self._grid = grid
        self._start, self._end = borders_from_radius(p, r, grid_size(grid))
        self._availability_mask = create_square_rhombus(p, r, grid_size(grid))

        if mask is not None:
            self._availability_mask &= mask

    def get(self, key: int2, default: R = None) -> T | R:
        if not fits_in_grid(self._grid, key) or not self._availability_mask[key]:
            return default

        return grid_unsafe_get(self._grid, key)

    def values(self) -> Iterator[T | None]:
        return (
            grid_unsafe_get(self._grid, (x, y))
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._availability_mask[x, y]
        )

    def items(self) -> Iterator[tuple[int2, T | None]]:
        return (
            ((x, y), grid_unsafe_get(self._grid, (x, y)))
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._availability_mask[x, y]
        )

    def __iter__(self) -> Iterator[int2]:
        return (
            (x, y)
            for x in range(self._start[0], self._end[0])
            for y in range(self._start[1], self._end[1])
            if self._availability_mask[x, y]
        )

    def __contains__(self, item: int2) -> bool:
        return fits_in_grid(self._grid, item) and self._availability_mask[item]


@dataclass
class Perception:
    vision: dict[str, GridProxy[Positioned]]
    hearing: GridProxy[Sound]
    smell: GridProxy[Positioned]


def borders_from_radius(p: int2, r: int, size: int2) -> tuple[int2, int2]:
    return (
        (max(0, p[0] - r), max(0, p[1] - r)),
        (min(size[0], p[0] + r + 1), min(size[1], p[1] + r + 1)),
    )


def create_square_rhombus(position, radius, field_size):  # TODO NEXT move this
    return numpy.fromfunction(
        lambda x, y: abs(x - position[0]) + abs(y - position[1]) <= radius,
        field_size
    )
