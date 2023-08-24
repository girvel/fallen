import curses
import logging

from ecs import Metasystem

from src.entities.controller import controller
from src.entities.level import level
from src.lib.vector import Vector, up, zero
from src.systems.display import clear_canvas, fill_canvas, display_canvas
from src.systems.input import read_input
from src.systems.movement import move

if __name__ == '__main__':
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)
    log = logging.getLogger(__name__)

    log.info("Game initialization")

    ms = Metasystem()

    for system in [
        clear_canvas,
        fill_canvas,
        display_canvas,
        read_input,
        move,
    ]:
        ms.add(system)

    level = ms.add(level)
    ms.add(controller)

    ms.create(name='game_camera', display_canvas=None, size=Vector(60, 20))
    controller.controls = level.put(ms.create(name='player_character', character='@'), Vector(5, 5))
    level.put(ms.create(name='tree', character='T'), Vector(7, 10))
    level.put(ms.create(name='tree', character='T'), Vector(3, 12))

    log.info("Curses initialization")

    @curses.wrapper
    def main(stdscr):
        ms.create(name='screen', main=stdscr, screen_flag=None)

        log.info("Started game cycle")
        try:
            while True:
                ms.update()
        finally:
            log.info("Ended game cycle")
