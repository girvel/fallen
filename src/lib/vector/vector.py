from statistics import mean, median
from typing import Tuple

from src.lib.toolkit import sign

zero = (0, 0)
one  = (1, 1)

up    = ( 0, -1)
down  = ( 0,  1)
right = ( 1,  0)
left  = (-1,  0)

directions = [up, down, right, left]


int2 = Tuple[int, int]

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


def d2(v1: int2, v2: int2) -> int:
    return abs(v1[0] - v2[0]) + abs(v1[1] - v2[1])


def average2(vs: list[int2]) -> int2:
    return tuple(mean(v[i] for v in vs) for i in range(2))

def median2(vs: list[int2]) -> int2:
    return tuple(median(v[i] for v in vs) for i in range(2))


