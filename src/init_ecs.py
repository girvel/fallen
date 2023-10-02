import logging
from pathlib import Path
from time import time

from ecs import Metasystem

from src.entities.ais.io import IO
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level
from src.lib.toolkit import crash_safe
from src.systems import acting, destruction_and_creation, ai, death


def init(stdscr, track, debug_mode, no_render, no_rails):
    logging.info("Creating & filling the metasystem")
    ms = Metasystem()

    logging.info("Initializing systems")

    for system in [
        # *regeneration.sequence,
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
        no_rails,
    ))

    level.query(lambda e: e.character == "@").unwrap().ai = (
        IO(stdscr, debug_track=track, debug_mode=debug_mode, no_render=no_render)
    )

    logging.info("Starting game cycle")

    t = time()
    update_counter = 0
    try:
        while True:
            ms.update()
            update_counter += 1
    except KeyboardInterrupt:
        pass
    except Exception as ex:
        logging.exception(ex)
    finally:
        t = time() - t

        logging.info("Finishing game cycle")
        logging.info(f"FPS: {update_counter / t:.2f}")