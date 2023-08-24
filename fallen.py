import curses
import logging
from pathlib import Path

from ecs import Metasystem

from src.entities.controller import Controller
from src.entities.level import Level
from src.lib.vector import Vector
from src.systems.display import clear_canvas, fill_canvas, display_canvas
from src.systems.input import read_input
from src.systems.movement import move

log = logging.getLogger(__name__)

if __name__ == '__main__':
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)
    log.info("Game initialization")

    ms = Metasystem()

    # Systems
    for system in [
        clear_canvas,
        fill_canvas,
        display_canvas,
        read_input,
        move,
    ]:
        ms.add(system)

    # Entities
    level = ms.add(Level())
    player = level.load(ms, Path("assets/level.txt"))

    ms.add(Controller(player))

    ms.create(name='game_camera', display_canvas=None, size=Vector(60, 20))
    screen = ms.create(name='screen', screen_flag=None)

    # Game cycle
    log.info("Curses initialization")

    @curses.wrapper
    def main(stdscr):
        screen.main = stdscr

        log.info("Started game cycle")
        try:
            while True:
                ms.update()
        finally:
            log.info("Ended game cycle")
            del screen.main
