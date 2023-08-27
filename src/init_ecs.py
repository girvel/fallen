import logging
from pathlib import Path

from ecs import Metasystem, create_system

from src.entities.effects.fire import Fire
from src.entities.special.level import Level
from src.entities.special.io import IO
from src.lib.vector import unsafe_set, add, right
from src.systems.ai import think
from src.systems.input import read_input
from src.systems.acting import act
from src.systems.temporal_components import remove_temporals

log = logging.getLogger(__name__)

def init(stdscr):
    log.info("Creating & filling the metasystem")
    ms = Metasystem()

    # Systems
    @create_system
    def destruction(hades: 'entities_to_destroy', level: 'physical_grid'):
        for e in hades.entities_to_destroy:
            if "p" in e:
                unsafe_set(level.physical_grid, e.p, None)

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

    io = ms.add(IO(stdscr))

    level = ms.add(Level())
    player = level.load(ms, Path("assets/level.txt"))

    player.ai = io
    io.connect_to_level(level)

    unsafe_set(level.effects_grid, add(player.p, right), ms.add(Fire()))

    # Game cycle
    log.info("Starting game cycle")
    try:
        while True:
            ms.update()
    except Exception as ex:
        log.exception(ex)
    finally:
        log.info("Finishing game cycle")