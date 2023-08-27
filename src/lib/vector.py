from typing import Callable, TypeVar

zero = (0, 0)
one  = (1, 1)

up    = ( 0, -1)
down  = ( 0,  1)
right = ( 1,  0)
left  = (-1,  0)


int2 = (int, int)

def add2(v1: int2, v2: int2) -> int2:
    return v1[0] + v2[0], v1[1] + v2[1]

def sub2(v1: int2, v2: int2) -> int2:
    return v1[0] - v2[0], v1[1] - v2[1]

def floordiv2(v: int2, k: int) -> int2:
    return v[0] // k, v[1] // k

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

def unsafe_set2(grid: (list[list[T]], int2), p: int2, value: T):
    array, size = grid
    assert ge2(p, zero) and lt2(p, size), f"Can not set grid cell at {p} outside of (0, 0) - {size}"
    array[p[1]][p[0]] = value

def safe_get2(grid: (list[list[T]], int2), p: int2, default: T = None) -> T:
    array, size = grid
    return (ge2(p, zero) and lt2(p, size)
        and array[p[1]][p[0]]
        or default
    )
