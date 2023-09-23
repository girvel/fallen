All the cool tools developed to simplify the writing of the code:

# ECS library

Allows to easily define systems (from pattern Entity-Component-System) using function syntax:

```python
@create_system
def destruction(hades: 'entities_to_destroy', genesis: 'entities_to_create', level: 'grids'):
    for e in hades.entities_to_destroy:
        if hasattr(e, "p"):
            grid_set(level.grids[e.layer], e.p, None)

        if hasattr(e, "on_death"):
            e.on_death(hades, genesis, level)

        ms.delete(e)
        logging.info(f"Destroyed entity {~Query(e).name}")

    hades.entities_to_destroy.clear()
```

Iterates over all entities that have required fields in all possible combinations. Requirements are described through annotation syntax. Usually one or zero arguments actually receive multiple different entities on each tick; typical argument (for example, all arguments in the example above) receives the same entity every tick and is used to retreive required entities from the pool, allowing to escape the need to import mutable state.

# Query

Allows to remove long walls of hasattrs from the code. `~Query(e).a.b` returns None if any of the `e`, `e.a`, `e.a.b` is None or else returns the value of `e.a.b`.

# Rust enums

Just a straightforward copy of Rust enums. Works nicely with new Python's match statement and walrus operator. Has `Option`s with `.unwrap()`, `.unwrap_or()` and everything. Even has a nice wrapper for built-in `next()`, `Option.next()`, which never raises an exception and instead returns `Option.Nothing` if nothing was found or else `Option.Some(value)`. It is really useful because you get a lot of `None`-related errors near `next`s because you forgot to specify what should happen if `None` is returned. Also options are fairly useful in AI modules, where you have to process a bunch of submodules, and each of them conditionally returns something.