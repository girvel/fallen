import inspect


def remove_temporals(container: "receives_damage"):
    del container.receives_damage

def act(actor: 'act', hades: 'entities_to_destroy', genesis: 'entities_to_create'):
    if actor.act is None: return

    if not inspect.isgeneratorfunction(actor.act.execute):
        return actor.act.execute(actor, hades, genesis)

    yield from actor.act.execute(actor, hades, genesis)

sequence = [remove_temporals, act]
