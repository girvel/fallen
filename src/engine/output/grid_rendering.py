import curses


def put_string_on_grid(grid, p, string, attributes):
    x, y = p
    array, (w, h) = grid
    i = 0

    if y >= h: return x, y

    while True:
        if x >= w:
            x = 0
            y += 1

            if y >= h: break

        if i >= len(string): break

        if y >= 0:
            array[y][x] = (string[i], attributes)

        i += 1
        x += 1

    return x, y


def render_grid(grid, window: curses.window):
    array, (w, h) = grid
    window.move(0, 0)

    for y in range(0, h):
        for x in range(0, w):
            if y == h - 1 and x == w - 1: break

            window.addstr(*array[y][x])
