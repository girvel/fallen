zero = (0, 0)
one  = (1, 1)

up    = ( 0, -1)
down  = ( 0,  1)
right = ( 1,  0)
left  = (-1,  0)


def add2(v1, v2):
    return v1[0] + v2[0], v1[1] + v2[1]

def sub2(v1, v2):
    return v1[0] - v2[0], v1[1] - v2[1]

def floordiv2(v, k):
    return v[0] // k, v[1] // k

def gt2(v1, v2):
    return v1[0] > v2[0] and v1[1] > v2[1]

def ge2(v1, v2):
    return v1[0] >= v2[0] and v1[1] >= v2[1]

def lt2(v1, v2):
    return gt2(v2, v1)

def le2(v1, v2):
    return ge2(v2, v1)

def create_grid(size, filler):
    return [[filler() for _ in range(size[0])] for _ in range(size[1])], size

def unsafe_set2(grid, p, value):
    array, size = grid
    assert ge2(p, zero) and lt2(p, size), f"Can not set grid cell at {p} outside of (0, 0) - {size}"
    array[p[1]][p[0]] = value

def safe_get2(grid, p, default=None):
    array, size = grid
    return (ge2(p, zero) and lt2(p, size)
        and array[p[1]][p[0]]
        or default
    )
