import inspect

from src.components import Killer, Healthy, Actor, Destructor, Creator

sequence = []

@sequence.append
def clean_up_kills(container: Killer):
    del container.last_killed

@sequence.append
def clean_up_health(container: Healthy):
    container.health.last_damaged_by.clear()  # TODO this is bullshit

@sequence.append
def act(actor: Actor, hades: Destructor, genesis: Creator):
    if actor.act is None: return

    if not inspect.isgeneratorfunction(actor.act.execute):
        return actor.act.execute(actor, hades, genesis)

    yield from actor.act.execute(actor, hades, genesis)
