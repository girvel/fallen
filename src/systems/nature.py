from src.lib import vector
from src.lib.toolkit import chance
from src.lib.vector import fits_in_grid, add2, grid_unsafe_get

sequence = []

@sequence.append
def flow(subject: "liquid_height", genesis: "entities_to_create"):
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
        elif grid_unsafe_get(subject.level.grids.physical, p) is None:
            subject.liquid_height -= 1
            genesis.entities_to_create.add(type(subject)(level=subject.level, p=p, liquid_height=1))

        if subject.liquid_height <= 1: return
