from ecs import create_system


@create_system
def information_cleanup(sphere: 'information_grid'):
    sphere.information_grid.clear()
