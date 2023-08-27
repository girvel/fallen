import logging
from pathlib import Path

from ecs import Metasystem, create_system

from src.entities.special.level import Level
from src.entities.ais.io import IO
from src.lib.vector import unsafe_set2
from src.systems.ai import think
from src.systems.acting import act
from src.systems.temporal_components import remove_temporals

log = logging.getLogger(__name__)

def init(stdscr, track=None):
    log.info("Creating & filling the metasystem")
    ms = Metasystem()

    # Systems
    @create_system
    def destruction(hades: 'entities_to_destroy', level: 'physical_grid'):
        for e in hades.entities_to_destroy:
            if "p" in e:
                unsafe_set2(level.physical_grid, e.p, None)

            ms.delete(e)

        hades.entities_to_destroy.clear()

    for system in [
        think,
        *remove_temporals,  # TODO these should be separate functions
        act,
        destruction,
    ]:
        ms.add(system)

    # Entities
    ms.create(name='hades', entities_to_destroy=[])

    level = ms.add(Level(ms, Path("assets/level.txt")))
    io = IO(stdscr, debug_track=track)
    level.player.ai = io
    io.connect_to_level(level)

    # Game cycle
    log.info("Starting game cycle")
    try:
        while True:
            ms.update()
    except Exception as ex:
        log.exception(ex)
    finally:
        log.info("Finishing game cycle")