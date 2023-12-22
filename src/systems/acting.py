import inspect

from src.components import Killer, Damaged, Actor, Hades, Genesis

sequence = []

@sequence.append
def clean_up_kills(container: Killer):
    del container.last_killed

@sequence.append
def clean_up_damage_statistics(container: Damaged):
    del container.last_damaged_by

@sequence.append
def act(actor: Actor, hades: Hades, genesis: Genesis):
    if actor.act is None: return

    if not inspect.isgeneratorfunction(actor.act.execute):
        return actor.act.execute(actor, hades, genesis)

    yield from actor.act.execute(actor, hades, genesis)
