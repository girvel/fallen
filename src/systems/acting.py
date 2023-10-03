from ecs import create_system


@create_system
def remove_temporals(container: "receives_damage"):
    del container.receives_damage

@create_system
def act(actor: 'act', hades: 'entities_to_destroy', genesis: 'entities_to_create'):
    if actor.act is None: return
    actor.act.execute(actor, actor.level, hades, genesis)  # TODO remove level argument

sequence = [remove_temporals, act]
