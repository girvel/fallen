import logging
from collections import Counter

from ecs import MetasystemFacade

from src.components import Hades, Genesis, Positioned
from src.lib.query import Q
from src.lib.toolkit import matches_protocol
from src.library.special.level import Level

sequence = []


@sequence.append
def destruction(hades: Hades, genesis: Genesis, ms: MetasystemFacade):
    counter = Counter()

    for entity in hades.entities_to_destroy:
        if ~Q(entity).on_destruction(hades, genesis): continue  # TODO vulnerability, can change iterable

        # TODO OPT runtime_checkable protocols native type checking is slow, rewrite
        if isinstance(entity, Positioned):
            Level.remove(entity)

        ms.remove(entity)

        if not hasattr(entity, "boring_flag"):
            counter[str(~Q(entity).name or entity)] += 1

    if len(counter) > 0:
        logging.info("Destroyed: " + "".join(
            f"\n    - {name}" + (f" ({count})" if count > 1 else "")
            for name, count in counter.items())
        )

    hades.entities_to_destroy.clear()


@sequence.append
def creation(genesis: Genesis, ms: MetasystemFacade):
    counter = Counter()

    for entity in genesis.entities_to_create:
        if matches_protocol(entity, Positioned):
            Level.put(entity)

        ms.add(entity)
        if not hasattr(entity, "boring_flag"):
            counter[str(~Q(entity).name or entity)] += 1

    if len(counter) > 0:
        logging.info("Created: " + "".join(
            f"\n    + {name}" + (f" ({count})" if count > 1 else "")
            for name, count in counter.items())
        )


@sequence.append
def after_creation(genesis: Genesis):
    for entity in genesis.entities_to_create:
        if hasattr(entity, "after_creation"):
            entity.after_creation()

    genesis.entities_to_create.clear()
