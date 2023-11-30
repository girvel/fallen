import logging

from ecs import Metasystem

from src.lib.query import Q
from src.lib.vector import grid_set, grid_get


def generate(ms: Metasystem):
    def destruction(hades: 'entities_to_destroy', genesis: 'entities_to_create'):
        for e in hades.entities_to_destroy:
            if (level := ~Q(e).level) is not None:
                grid_set(level.grids[e.layer], e.p, None)

            if hasattr(e, "on_death"):
                if e.on_death(e, hades, genesis):
                    ms.delete(e)
            else:
                ms.delete(e)

            if not hasattr(e, "sound_flag") and not hasattr(e, "boring_flag"):
                logging.info(f'-"{~Q(e).name or e}"')

        hades.entities_to_destroy.clear()

    def creation(hades: 'entities_to_destroy', genesis: 'entities_to_create'):
        for e in genesis.entities_to_create:
            if hasattr(e, "level"):
                if (replaced := grid_get(e.level.grids[e.layer], e.p)) is not None:
                    hades.entities_to_destroy.add(replaced)
                    replaced.level = None

                e.level.put(e.p, e)

            ms.add(e)
            if not hasattr(e, "sound_flag") and not hasattr(e, "boring_flag"):
                logging.info(f'+"{~Q(e).name or e}"')

        genesis.entities_to_create.clear()

    return creation, destruction