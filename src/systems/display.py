import os

from ecs import create_system


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