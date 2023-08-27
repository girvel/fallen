from ecs import create_system


@create_system
def act(actor: 'act', level: 'physical_grid', hades: 'entities_to_destroy'):
    actor.act.execute(actor, level, hades)
    del actor.act