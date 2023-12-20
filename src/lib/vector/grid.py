from typing import TypeVar, Callable

from src.lib.vector.vector import int2, ge2, zero, lt2

T = TypeVar('T')
R = TypeVar('R')


def grid_create(size: int2, filler: Callable[[], T]) -> tuple[list[list[T]], int2]:
    return [[filler() for _ in range(size[0])] for _ in range(size[1])], size


def grid_map(grid: tuple[list[list[T]], int2], f: Callable[[T], R]) -> tuple[list[list[R]], int2]:
    array, size = grid
    return [[f(e) for e in row] for row in array], size


def fits_in_grid(grid: tuple[list[list[T]], int2], p: int2) -> bool:
    return ge2(p, zero) and lt2(p, grid_size(grid))


def grid_set(grid: tuple[list[list[T]], int2], p: int2, value: T):
    grid[0][p[1]][p[0]] = value


def grid_get(grid: tuple[list[list[T]], int2], p: int2, default: T = None) -> T:
    return grid[0][p[1]][p[0]] if fits_in_grid(grid, p) else default


def grid_unsafe_get(grid: tuple[list[list[T]], int2], p: int2) -> T:
    return grid[0][p[1]][p[0]]


def grid_size(grid: tuple[list[list[T]], int2]) -> int2:
    return grid[1]
