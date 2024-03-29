from src.lib.vector.vector import int2


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

def iter_rect(borders: tuple[int2, int2], size: int2):
    return (
        (x, y)
        for y in range(
            max(min(borders[0][1], borders[1][1]), 0),
            min(max(borders[0][1], borders[1][1]), size[1])
        )
        for x in range(
            max(min(borders[0][0], borders[1][0]), 0),
            min(max(borders[0][0], borders[1][0]), size[0])
        )
    )

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

def iter_rhombus_from_center(p: int2, r: int):
    x, y = p
    yield x, y

    for current_r in range(1, r + 1):
        y -= 1

        for _ in range(current_r):
            yield x, y
            x += 1
            y += 1

        for _ in range(current_r):
            yield x, y
            x -= 1
            y += 1

        for _ in range(current_r):
            yield x, y
            x -= 1
            y -= 1

        for _ in range(current_r):
            yield x, y
            x += 1
            y -= 1
