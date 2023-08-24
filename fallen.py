import curses
import logging
from pathlib import Path

from ecs import Metasystem, OwnedEntity

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

    palette = {
        'T': OwnedEntity(name='tree', character='T'),
        '@': OwnedEntity(name='player_character', character='@'),
    }

    for y, line in enumerate(Path('assets/level.txt').read_text().split('\n')):
        for x, c in enumerate(line):
            if c == ".":
                continue

            assert c in palette
            e = level.put(ms.create(**dict(palette[c])), Vector(x, y))

            if c == "@":
                controller.controls = e

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
