import logging
from pathlib import Path
from time import time

from ecs import Metasystem, create_system

from src.engine import permanent_storage
from src.engine.input.hotkeys import GameEnd
from src.library.ais.io import IO
from src.library.physical.player import Player
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.library.special.level import Level
from src.lib.toolkit import crash_safe
from src.systems import acting, destruction_and_creation, ai, death, nature, clock


def build_metasystem(debug_mode):
    logging.info("Creating & filling the metasystem")
    ms = Metasystem()

    logging.info("Initializing systems")

    for system in map(create_system, [
        *clock.sequence,
        # *regeneration.sequence,
        *nature.sequence,
        *ai.sequence,
        *acting.sequence,
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


def init(stdscr, track, debug_mode, no_render, no_rails, no_fixed_fps):
    permanent_storage.initialize()

    ms, genesis = build_metasystem(debug_mode)

    level = ms.add(Level(ms, Path("assets/levels/main"), no_rails, genesis))

    next(level.find(Player)).ai = IO(
        stdscr, debug_track=track, debug_mode=debug_mode,
        is_render_enabled=not no_render, max_fps=None if no_fixed_fps else 10,
    )

    logging.info("Starting game cycle")

    t = time()
    update_counter = 0
    try:
        while True:
            ms.update()
            update_counter += 1
    except GameEnd:
        pass
    except Exception as ex:
        logging.error("Uncaught error on Metasystem.update", exc_info=ex)
        if debug_mode: raise ex
    finally:
        t = time() - t

        logging.info("Finishing game cycle")
        logging.info(f"FPS: {update_counter / t:.2f}")
