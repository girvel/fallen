import logging

from ecs import create_system, Metasystem

from src.lib.vector import grid_set


def generate(ms: Metasystem):
    @create_system
    def destruction(hades: 'entities_to_destroy', level: 'grids'):
        for e in hades.entities_to_destroy:
            if "p" in e:
                grid_set(level.grids[e.layer], e.p, None)

            ms.delete(e)
            logging.info(f"Destroyed entity {e}")

        hades.entities_to_destroy.clear()

    @create_system
    def creation(genesis: 'entities_to_create'):
        for e in genesis.entities_to_create:
            ms.add(e)
            logging.info(f"Created entity {e}")

        genesis.entities_to_create.clear()

    return destruction, creation