from collections.abc import Iterator
from dataclasses import dataclass
from enum import Enum
from typing import Any, TypeVar, Generic

import numpy
from numpy import ndarray, dtype

from src.components import Positioned
from src.lib.vector.iteration import iter_rhombus
from src.lib.vector.vector import int2, d2
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


Grid = tuple[list[list[Any]], int2]

@dataclass
class GridProxy:
    _grid: Grid
    _center: int2
    _r: int
    _availability_mask: ndarray[Any, dtype[bool]] | None = None

    def get(self, key: int2, default: Any = None) -> Any:
        if not fits_in_grid(self._grid, key) or not self._availability_mask[key]:
            return default

        return grid_unsafe_get(self._grid, key)

    def values(self) -> Iterator[Any]:
        return (
            grid_unsafe_get(self._grid, (x, y))
            for x, y in iter_rhombus(self._center, self._r, grid_size(self._grid))
            if self._availability_mask is None or self._availability_mask[x, y]
        )

    def items(self) -> Iterator[tuple[int2, Any]]:
        return (
            ((x, y), grid_unsafe_get(self._grid, (x, y)))
            for x, y in iter_rhombus(self._center, self._r, grid_size(self._grid))
            if self._availability_mask is None or self._availability_mask[x, y]
        )

    def __iter__(self) -> Iterator[int2]:
        return (
            (x, y)
            for x, y in iter_rhombus(self._center, self._r, grid_size(self._grid))
            if self._availability_mask is None or self._availability_mask[x, y]
        )

    def __contains__(self, item: int2) -> bool:
        return (
            d2(item, self._center) <= self._r and
            fits_in_grid(self._grid, item) and
            (self._availability_mask is None or self._availability_mask[item])
        )


@dataclass
class Perception:
    vision: dict[str, GridProxy]
    hearing: GridProxy
    smell: GridProxy
