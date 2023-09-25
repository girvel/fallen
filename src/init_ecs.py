import logging
from pathlib import Path

from ecs import Metasystem

from src.entities.ais.io import IO
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.entities.special.transparency_cache import TransparencyCache
from src.lib.toolkit import crash_safe
from src.lib.vector import grid_size
from src.systems import acting, destruction_and_creation, ai, death, regeneration


def init(stdscr, track, debug_mode, no_render):
    logging.info("Creating & filling the metasystem")
    ms = Metasystem()

    logging.info("Initializing systems")

    for system in [
        *regeneration.sequence,
        *ai.sequence,
        *acting.sequence,
        *death.sequence,
        *destruction_and_creation.generate(ms),
    ]:
        if not debug_mode:
            system.process = crash_safe(system.process)

        ms.add(system)

    logging.info("Creating special entities")

    ms.add(Hades())
    ms.add(Genesis())

    level = ms.add(Level(
        ms, Path("assets/levels/main"),
        IO(stdscr, debug_track=track, debug_mode=debug_mode, no_render=no_render)
    ))

    ms.add(TransparencyCache(grid_size(level.grids.physical)))

    logging.info("Starting game cycle")

    try:
        while True:
            ms.update()
    except KeyboardInterrupt:
        pass
    except Exception as ex:
        logging.exception(ex)
    finally:
        logging.info("Finishing game cycle")