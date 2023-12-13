import logging

from ecs import MetasystemFacade

from src.components import Destructor, Creator
from src.lib.query import Q
from src.lib.vector.grid import grid_set, grid_get

sequence = []

@sequence.append
def destruction(hades: Destructor, genesis: Creator, ms: MetasystemFacade):
    for e in hades.entities_to_destroy:
        if hasattr(e, "on_death") and e.on_death(hades, genesis):
            continue

        if (level := ~Q(e).level) is not None:
            grid_set(level.grids[e.layer], e.p, None)

        ms.remove(e)

        if not hasattr(e, "boring_flag"):
            logging.info(f'-"{~Q(e).name or e}"')

    hades.entities_to_destroy.clear()

@sequence.append
def creation(hades: Destructor, genesis: Creator, ms: MetasystemFacade):
    for e in genesis.entities_to_create:
        if hasattr(e, "level"):
            if (replaced := grid_get(e.level.grids[e.layer], e.p)) is not None:
                hades.entities_to_destroy.add(replaced)
                replaced.level = None

            e.level.put(e.p, e)

        ms.add(e)
        if not hasattr(e, "boring_flag"):
            logging.info(f'+"{~Q(e).name or e}"')

    genesis.entities_to_create.clear()
