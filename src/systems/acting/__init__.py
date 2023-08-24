from ecs import create_system


@create_system
def act(movable: 'p, act', level: 'level_grid', hades: 'entities_to_destroy'):
    movable.act.execute(movable, level, hades)