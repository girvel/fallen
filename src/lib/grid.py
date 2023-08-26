from src.lib import vector


def create_grid(size, filler):
    return [filler()] * size[0] * size[1], size

def set_in(grid, p, value):
    array, size = grid
    assert vector.less(size)
    return array[p[1] * size[0] + p[0]]
