import logging
from pathlib import Path

from ecs import Metasystem, create_system

from src.entities.effects.fire import Fire
from src.entities.special.level import Level
from src.entities.ais.io import IO
from src.lib.vector import unsafe_set2
from src.systems import acting
from src.systems.ai import think
from src.systems.death_by_chance import death_by_chance

log = logging.getLogger(__name__)

def init(stdscr, track, debug_mode):
    log.info("Creating & filling the metasystem")
    ms = Metasystem()

    # Systems
    @create_system
    def destruction(hades: 'entities_to_destroy', level: 'physical_grid'):
        for e in hades.entities_to_destroy:
            if "p" in e:
                unsafe_set2(level.physical_grid, e.p, None)

            if "tile_p" in e:
                unsafe_set2(level.tile_grid, e.tile_p, None)

            if "effect_p" in e:
                unsafe_set2(level.effect_grid, e.effect_p, None)

            ms.delete(e)

        hades.entities_to_destroy.clear()

    for system in [
        think,
        *acting.sequence,
        death_by_chance,
        destruction,
    ]:
        ms.add(system)

    # Entities
    ms.create(name='hades', entities_to_destroy=[])

    level = ms.add(Level(ms, Path("assets/levels/main"), IO(stdscr, debug_track=track, debug_mode=debug_mode)))
    level.put_effect((51, 3), ms.add(Fire(2)))

    # Game cycle
    log.info("Starting game cycle")
    try:
        while True:
            ms.update()
    except Exception as ex:
        log.exception(ex)
    finally:
        log.info("Finishing game cycle")