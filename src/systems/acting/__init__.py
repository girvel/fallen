# TODO move from ugly __init__.py
from ecs import create_system


@create_system
def remove_temporals(container: "receives_damage"):
    del container.receives_damage

@create_system
def act(actor: 'act', level: 'grids', hades: 'entities_to_destroy', genesis: 'entities_to_create'):
    if actor.act is None: return
    actor.act.execute(actor, level, hades, genesis)

sequence = [remove_temporals, act]
