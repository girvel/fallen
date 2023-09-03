from typing import Callable, TypeVar

from src.lib.toolkit import sign

zero = (0, 0)
one  = (1, 1)

up    = ( 0, -1)
down  = ( 0,  1)
right = ( 1,  0)
left  = (-1,  0)

directions = [up, down, right, left]


int2 = (int, int)

def add2(v1: int2, v2: int2) -> int2:
    return v1[0] + v2[0], v1[1] + v2[1]

def sub2(v1: int2, v2: int2) -> int2:
    return v1[0] - v2[0], v1[1] - v2[1]

def mul2(v: int2, k: int) -> int2:
    return v[0] * k, v[1] * k

def floordiv2(v: int2, k: int) -> int2:
    return v[0] // k, v[1] // k

def abs2(v: int2) -> int:
    return abs(v[0]) + abs(v[1])

def sign2(v: int2) -> int2:
    return sign(v[0]), sign(v[1])

def area2(v: int2) -> int:
    return v[0] * v[1]

def flip2(v: int2) -> int2:
    return v[1], v[0]

def gt2(v1: int2, v2: int2) -> int2:
    return v1[0] > v2[0] and v1[1] > v2[1]

def ge2(v1: int2, v2: int2) -> int2:
    return v1[0] >= v2[0] and v1[1] >= v2[1]

def lt2(v1: int2, v2: int2) -> int2:
    return gt2(v2, v1)

def le2(v1: int2, v2: int2) -> int2:
    return ge2(v2, v1)

T = TypeVar('T')
def create_grid(size: int2, filler: Callable[[], T]) -> (list[list[T]], int2):
    return [[filler() for _ in range(size[0])] for _ in range(size[1])], size

R = TypeVar('R')
def map_grid(grid: (list[list[T]], int2), f: Callable[[T], R]) -> (list[list[R]], int2):
    array, size = grid
    return [[f(e) for e in row] for row in array], size

def fits_in_grid(grid: (list[list[T]], int2), p: int2) -> bool:
    return ge2(p, zero) and lt2(p, size2(grid))

def unsafe_set2(grid: (list[list[T]], int2), p: int2, value: T):
    array, size = grid
    assert ge2(p, zero) and lt2(p, size), f"Can not set grid cell at {p} outside of (0, 0) - {size}"
    array[p[1]][p[0]] = value

def safe_get2(grid: (list[list[T]], int2), p: int2, default: T = None) -> T:
    array, size = grid
    return array[p[1]][p[0]] if fits_in_grid(grid, p) else default

def size2(grid: (list[list[T]], int2)) -> int2:
    return grid[1]
