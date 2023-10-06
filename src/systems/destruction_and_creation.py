import logging

from ecs import create_system, Metasystem

from src.lib.query import Query
from src.lib.vector import grid_set, grid_get


def generate(ms: Metasystem):
    @create_system
    def destruction(hades: 'entities_to_destroy', genesis: 'entities_to_create'):
        for e in hades.entities_to_destroy:
            if (level := ~Query(e).level) is not None:
                grid_set(level.grids[e.layer], e.p, None)

            if hasattr(e, "on_death"):
                if e.on_death(hades, genesis):
                    ms.delete(e)
            else:
                ms.delete(e)

            if not hasattr(e, "sound_flag"):
                logging.info(f'-"{~Query(e).name or e}"')

        hades.entities_to_destroy.clear()

    @create_system
    def creation(hades: 'entities_to_destroy', genesis: 'entities_to_create'):
        for e in genesis.entities_to_create:
            if hasattr(e, "level"):
                if (replaced := grid_get(e.level.grids[e.layer], e.p)) is not None:
                    hades.entities_to_destroy.add(replaced)
                    replaced.level = None

                e.level.put(e.p, e)

            ms.add(e)
            if not hasattr(e, "sound_flag"):
                logging.info(f'+"{~Query(e).name or e}"')

        genesis.entities_to_create.clear()

    return creation, destruction