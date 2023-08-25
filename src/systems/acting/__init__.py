from ecs import create_system


@create_system
def act(actor: 'p, act', level: 'level_grid', hades: 'entities_to_destroy'):
    if actor.act is None: return
    actor.act.execute(actor, level, hades)