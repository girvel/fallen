from src.lib.vector.vector import int2


def iter_rhombus(p: int2, r: int, size: int2):
    return (
        (x, y)
        for y in range(
            max(p[1] - r, 0),
            min(p[1] + r + 1, size[1])
        )
        for x in range(
            max(p[0] + abs(y - p[1]) - r, 0),
            min(p[0] + r - abs(y - p[1]) + 1, size[0]),
        )
    )

def iter_square(p: int2, r: int, size: int2):
    return (
        (x, y)
        for y in range(
            max(p[1] - r, 0),
            min(p[1] + r + 1, size[1])
        )
        for x in range(
            max(p[0] - r, 0),
            min(p[0] + r + 1, size[0])
        )
    )
