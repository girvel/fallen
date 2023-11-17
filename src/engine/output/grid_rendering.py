import curses


def put_string_on_grid(grid, p, string, attributes, invert_horizontally=False, invert_vertically=False):
    x, y = p
    array, (w, h) = grid
    i = 0

    dx = -1 if invert_horizontally else 1
    dy = -1 if invert_vertically else 1

    if y >= h: return x, y

    while True:
        if invert_horizontally:
            if x < 0:
                x = w - 1
                y += dy
        else:
            if x >= w:
                x = 0
                y += dy

        if i >= len(string): break

        if 0 <= y < w and 0 <= x < w:
            array[y][x] = (string[i], attributes)

        i += 1
        x += dx

    return x, y


def render_grid(grid, window: curses.window):
    array, (w, h) = grid
    window.move(0, 0)

    for y in range(0, h):
        for x in range(0, w):
            if y == h - 1 and x == w - 1: break

            window.addstr(*array[y][x])
