zero = (0, 0)
one  = (1, 1)

up    = ( 0, -1)
down  = ( 0,  1)
right = ( 1,  0)
left  = (-1,  0)


def add(v1, v2):
    return v1[0] + v2[0], v1[1] + v2[1]

def sub(v1, v2):
    return v1[0] - v2[0], v1[1] - v2[1]

def floordiv(v, k):
    return v[0] // k, v[1] // k

def gt(v1, v2):
    return v1[0] > v2[0] and v1[1] > v2[1]

def ge(v1, v2):
    return v1[0] >= v2[0] and v1[1] >= v2[1]

def lt(v1, v2):
    return gt(v2, v1)

def le(v1, v2):
    return ge(v2, v1)

def create_grid(size, filler):
    return [[filler() for _ in range(size[0])] for _ in range(size[1])], size

def unsafe_set(grid, p, value):
    array, size = grid
    assert ge(p, zero) and lt(p, size), f"Can not set grid cell at {p} outside of (0, 0) - {size}"
    array[p[1]][p[0]] = value

def safe_get(grid, p):
    array, size = grid
    return (ge(p, zero) and lt(p, size)
        and array[p[1]][p[0]]
        or None
    )
