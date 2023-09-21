import logging
from pathlib import Path

from ecs import Metasystem
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.entities.ais.io import IO
from src.entities.special.transparency_cache import TransparencyCache
from src.lib.vector import grid_size
from src.systems import acting, destruction_and_creation, ai
from src.systems.death_by_chance import death_by_chance


def init(stdscr, track, debug_mode):
    logging.info("Creating & filling the metasystem")
    ms = Metasystem()

    logging.info("Initializing systems")

    for system in [
        *ai.sequence,
        *acting.sequence,
        death_by_chance,
        *destruction_and_creation.generate(ms),
    ]:
        ms.add(system)

    logging.info("Creating special entities")

    ms.add(Hades())
    ms.add(Genesis())
    level = ms.add(Level(ms, Path("assets/levels/main"), IO(stdscr, debug_track=track, debug_mode=debug_mode)))
    ms.add(TransparencyCache(grid_size(level.grids.physical)))

    logging.info("Starting game cycle")

    try:
        while True:
            ms.update()
    except Exception as ex:
        logging.exception(ex)
    finally:
        logging.info("Finishing game cycle")