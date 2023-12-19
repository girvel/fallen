import logging

from ecs import MetasystemFacade

from src.components import Hades, Genesis
from src.lib.query import Q
from src.lib.vector.grid import grid_set

sequence = []


@sequence.append
def destruction(hades: Hades, genesis: Genesis, ms: MetasystemFacade):
    for entity in hades.entities_to_destroy:
        if hasattr(entity, "on_destruction") and entity.on_destruction(hades, genesis):
            continue

        if (level := ~Q(entity).level) is not None:
            grid_set(level.grids[entity.layer], entity.p, None)  # TODO NEXT level.remove

        ms.remove(entity)

        if not hasattr(entity, "boring_flag"):
            logging.info(f'-"{~Q(entity).name or entity}"')

    hades.entities_to_destroy.clear()


@sequence.append
def creation(genesis: Genesis, ms: MetasystemFacade):
    for entity in genesis.entities_to_create:
        # TODO NEXT ecs.has_component()
        if hasattr(entity, "level") and hasattr(entity, "p") and hasattr(entity, "layer"):
            entity.level.put(entity.p, entity)

        ms.add(entity)
        if not hasattr(entity, "boring_flag"):
            logging.info(f'+"{~Q(entity).name or entity}"')


@sequence.append
def after_creation(genesis: Genesis):
    for entity in genesis.entities_to_create:
        if hasattr(entity, "after_creation"):
            entity.after_creation()

    genesis.entities_to_create.clear()
