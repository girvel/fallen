import logging

from ecs import create_system, Metasystem

from src.lib.query import Query
from src.lib.vector import grid_set, grid_get


def generate(ms: Metasystem):
    @create_system
    def destruction(hades: 'entities_to_destroy', genesis: 'entities_to_create', level: 'grids'):
        for e in hades.entities_to_destroy:
            if hasattr(e, "p"):
                grid_set(level.grids[e.layer], e.p, None)

            if hasattr(e, "on_death"):
                e.on_death(hades, genesis, level)

            ms.delete(e)
            logging.info(f"Destroyed entity {~Query(e).name}")

        hades.entities_to_destroy.clear()

    @create_system
    def creation(genesis: 'entities_to_create', level: 'grids'):
        for e in genesis.entities_to_create:
            if hasattr(e, "p"):
                if (replaced := grid_get(level.grids[e.layer], e.p)) is not None:
                    logging.warning(f"Replacing {~Query(replaced).name} in {e.layer} at {e.p}")

                level.put(e.p, e)

            ms.add(e)
            logging.info(f"Created entity {~Query(e).name}")

        genesis.entities_to_create.clear()

    return destruction, creation