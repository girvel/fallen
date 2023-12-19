import logging

from ecs import MetasystemFacade

from src.components import Hades, Genesis, Positioned
from src.lib.query import Q
from src.lib.vector.grid import grid_set
from src.library.special.level import Level

sequence = []


@sequence.append
def destruction(hades: Hades, genesis: Genesis, ms: MetasystemFacade):
    for entity in hades.entities_to_destroy:
        if ~Q(entity).on_destruction(hades, genesis): continue

        # TODO OPT runtime_checkable protocols native type checking is slow, rewrite
        if isinstance(entity, Positioned):
            Level.remove(entity)

        ms.remove(entity)

        if not hasattr(entity, "boring_flag"):
            logging.info(f'-"{~Q(entity).name or entity}"')

    hades.entities_to_destroy.clear()


@sequence.append
def creation(genesis: Genesis, ms: MetasystemFacade):
    for entity in genesis.entities_to_create:
        # TODO OPT runtime_checkable protocols native type checking is slow, rewrite
        if isinstance(entity, Positioned):
            Level.put(entity)

        ms.add(entity)
        if not hasattr(entity, "boring_flag"):
            logging.info(f'+"{~Q(entity).name or entity}"')


@sequence.append
def after_creation(genesis: Genesis):
    for entity in genesis.entities_to_create:
        if hasattr(entity, "after_creation"):
            entity.after_creation()

    genesis.entities_to_create.clear()
