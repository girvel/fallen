import os

from ecs import Metasystem, create_system
from src.lib.vector import Vector
import keyboard


if __name__ == '__main__':
    ms = Metasystem()

    @create_system
    def clear_canvas(camera: 'display_canvas'):
        camera.display_canvas = camera.size.create_grid(".")

    @create_system
    def fill_canvas(
        subject: 'p, character',
        camera: 'display_canvas',
    ):
        if not (subject.p <= camera.size):
            return

        camera.display_canvas[subject.p.y][subject.p.x] = subject.character

    @create_system
    def display_canvas(camera: 'display_canvas'):
        os.system("cls||clear")
        for line in camera.display_canvas:
            print(''.join(line))

    @create_system
    def read_input(pc: 'player_character_flag'):
        keyboard.read_key()

    ms.add(clear_canvas)
    ms.add(fill_canvas)
    ms.add(display_canvas)
    ms.add(read_input)

    ms.create(name='game_camera', display_canvas=None, size=Vector(60, 20))
    ms.create(name='player_character', p=Vector(5, 5), character='@', player_character_flag=None)

    while True:
        ms.update()
