import inspect


sequence = []

@sequence.append
def clean_up_health(container: "health"):
    container.health.last_damaged_by.clear()

@sequence.append
def act(actor: 'act', hades: 'entities_to_destroy', genesis: 'entities_to_create'):
    if actor.act is None: return

    if not inspect.isgeneratorfunction(actor.act.execute):
        return actor.act.execute(actor, hades, genesis)

    yield from actor.act.execute(actor, hades, genesis)
