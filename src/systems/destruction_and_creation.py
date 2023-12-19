import logging

from ecs import MetasystemFacade

from src.components import Destructor, Creator
from src.lib.query import Q
from src.lib.vector.grid import grid_set, grid_get

sequence = []


@sequence.append
def destruction(hades: Destructor, genesis: Creator, ms: MetasystemFacade):
    for entity in hades.entities_to_destroy:
        if hasattr(entity, "on_destruction") and entity.on_destruction(hades, genesis):
            continue

        if (level := ~Q(entity).level) is not None:
            grid_set(level.grids[entity.layer], entity.p, None)

        ms.remove(entity)

        if not hasattr(entity, "boring_flag"):
            logging.info(f'-"{~Q(entity).name or entity}"')

    hades.entities_to_destroy.clear()


@sequence.append
def creation(hades: Destructor, genesis: Creator, ms: MetasystemFacade):
    for entity in genesis.entities_to_create:
        if hasattr(entity, "level"):
            if (replaced := grid_get(entity.level.grids[entity.layer], entity.p)) is not None:
                hades.entities_to_destroy.add(replaced)
                replaced.level = None

            entity.level.put(entity.p, entity)

        ms.add(entity)
        if not hasattr(entity, "boring_flag"):
            logging.info(f'+"{~Q(entity).name or entity}"')


@sequence.append
def after_creation(genesis: Creator):
    for entity in genesis.entities_to_create:
        if hasattr(entity, "after_creation"):
            entity.after_creation()

    genesis.entities_to_create.clear()
