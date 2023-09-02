from ecs import create_system


@create_system
def remove_temporals(container: "receives_damage"):
    del container.receives_damage

@create_system
def act(actor: 'act', level: 'grids', hades: 'entities_to_destroy'):
    if actor.act is None: return
    actor.act.execute(actor, level, hades)

sequence = [remove_temporals, act]
