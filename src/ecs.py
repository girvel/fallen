import logging

from ecs import MetasystemFacade, System

from src.lib.toolkit import crash_safe
from src.components import Genesis, Hades
from src.systems import acting, destruction_and_creation, ai, death, nature, clock, blinking


def build_metasystem(debug_mode):
    logging.info("Creating & filling the metasystem")
    ms = MetasystemFacade()

    logging.info("Initializing systems")

    for system in map(System, [
        # micro-processes:
        *blinking.sequence,
        *clock.sequence,
        # *regeneration.sequence,

        # nature:
        *nature.sequence,

        # ai/acting:
        *ai.sequence,
        *acting.sequence,

        # death:
        *death.sequence,
        *destruction_and_creation.sequence,
    ]):
        if not debug_mode:
            system.ecs_process = crash_safe(system.ecs_process)

        ms.add(system)

    ms.register_itself()

    return ms, ms.add(Hades()), ms.add(Genesis())
