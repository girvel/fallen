import logging

from ecs import Metasystem

from src.entities import controller
from src.lib.vector import Vector, up
from src.systems.display import clear_canvas, fill_canvas, display_canvas
from src.systems.input import read_input

if __name__ == '__main__':
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)

    ms = Metasystem()

    for system in [
        clear_canvas,
        fill_canvas,
        display_canvas,
        read_input,
    ]:
        ms.add(system)

    ms.create(name='game_camera', display_canvas=None, size=Vector(60, 20))
    pc = ms.create(name='player_character', p=Vector(5, 5), character='@', player_character_flag=None)
    ms.add(controller.create(pc))

    while True:
        ms.update()
