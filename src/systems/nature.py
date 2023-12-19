from src.components import Liquid, Genesis
from src.lib.vector import vector
from src.lib.toolkit import chance
from src.lib.vector.vector import add2
from src.lib.vector.grid import fits_in_grid, grid_unsafe_get

sequence = []

@sequence.append
def flow(subject: Liquid, genesis: Genesis):
    if subject.liquid_height <= 1: return

    grid = subject.level.grids[subject.layer]

    for d in vector.directions:
        p = add2(subject.p, d)
        if not fits_in_grid(grid, p): continue
        other = grid_unsafe_get(grid, p)

        if hasattr(other, "liquid_height"):
            diff = subject.liquid_height - other.liquid_height

            if diff >= 2 or diff == 1 and chance(.5):
                subject.liquid_height -= 1
                other.liquid_height += 1
        elif grid_unsafe_get(subject.level.grids["physical"], p) is None:
            subject.liquid_height -= 1
            genesis.push(type(subject)(level=subject.level, p=p, liquid_height=1))

        if subject.liquid_height <= 1: return
