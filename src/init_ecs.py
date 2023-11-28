import logging

from ecs import Metasystem, create_system

from src.lib.toolkit import crash_safe
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.systems import acting, destruction_and_creation, ai, death, nature, clock, blinking


def build_metasystem(debug_mode):
    logging.info("Creating & filling the metasystem")
    ms = Metasystem()

    logging.info("Initializing systems")

    for system in map(create_system, [
        # microprocesses:
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
        *destruction_and_creation.generate(ms),
    ]):
        if not debug_mode:
            system.process = crash_safe(system.process)

        ms.add(system)

    logging.info("Creating special entities")

    ms.add(Hades())
    genesis = ms.add(Genesis())

    return ms, genesis
