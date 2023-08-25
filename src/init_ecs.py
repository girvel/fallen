import logging
from pathlib import Path

from ecs import Metasystem, create_system

from src.entities.special.controller import Controller
from src.entities.special.level import Level
from src.entities.special.screen import Screen
from src.systems.ai import attack_if_possible
from src.systems.display import display_canvas
from src.systems.input import read_input
from src.systems.acting import act
from src.systems.temporal_components import remove_temporals

log = logging.getLogger(__name__)

def init(stdscr):
    log.info("Creating & filling the metasystem")
    ms = Metasystem()

    # Systems
    @create_system
    def destruction(hades: 'entities_to_destroy', level: 'level_grid'):
        for e in hades.entities_to_destroy:
            if "p" in e:
                e.p.set_in(level.level_grid, None)

            ms.delete(e)

        hades.entities_to_destroy.clear()

    for system in [
        read_input,
        attack_if_possible,
        act,
        display_canvas,
        *remove_temporals,
        destruction,
    ]:
        ms.add(system)

    # Entities
    ms.create(name='hades', entities_to_destroy=[])

    level = ms.add(Level())
    player = level.load(ms, Path("assets/level.txt"))

    ms.add(Controller(player))
    screen = ms.add(Screen(stdscr))

    # Game cycle
    log.info("Starting game cycle")
    try:
        while True:
            ms.update()
    finally:
        log.info("Finishing game cycle")
        del screen.main