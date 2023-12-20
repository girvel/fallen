from collections.abc import Iterator
from dataclasses import dataclass
from enum import Enum
from typing import Any, TypeVar, Generic

import numpy
from line_profiler import profile
from numpy import ndarray, dtype

from src.components import Positioned
from src.lib.vector.iteration import iter_rhombus
from src.lib.vector.vector import int2, d2
from src.lib.vector.grid import fits_in_grid, grid_unsafe_get, grid_size
from src.library.special.sound import Sound


@dataclass
class Senses:
    vision: int
    hearing: int
    smell: int


Grid = tuple[list[list[Any]], int2]

# TODO maybe derive MaskedGridProxy for speed?
@dataclass
class GridProxy:
    grid: Grid
    center: int2
    r: int
    availability_mask: ndarray[Any, dtype[bool]] | None = None

    def get(self, key: int2, default: Any = None) -> Any:
        if (
            not fits_in_grid(self.grid, key) or
            self.availability_mask is not None and not self.availability_mask[key]
        ):
            return default

        return grid_unsafe_get(self.grid, key)

    def values(self) -> Iterator[Any]:
        return (
            grid_unsafe_get(self.grid, (x, y))
            for x, y in iter_rhombus(self.center, self.r, grid_size(self.grid))
            if self.availability_mask is None or self.availability_mask[x, y]
        )

    def items(self) -> Iterator[tuple[int2, Any]]:
        return (
            ((x, y), grid_unsafe_get(self.grid, (x, y)))
            for x, y in iter_rhombus(self.center, self.r, grid_size(self.grid))
            if self.availability_mask is None or self.availability_mask[x, y]
        )

    def __iter__(self) -> Iterator[int2]:
        return (
            (x, y)
            for x, y in iter_rhombus(self.center, self.r, grid_size(self.grid))
            if self.availability_mask is None or self.availability_mask[x, y]
        )

    def __contains__(self, item: int2) -> bool:
        return (
            d2(item, self.center) <= self.r and
            fits_in_grid(self.grid, item) and
            (self.availability_mask is None or self.availability_mask[item])
        )

    @profile
    def unsafe_contains(self, item: int2) -> bool:
        return (
            d2(item, self.center) <= self.r and
            (self.availability_mask is None or self.availability_mask[item])
        )


@dataclass
class Perception:
    vision: dict[str, GridProxy]
    hearing: GridProxy
    smell: GridProxy
