from dataclasses import make_dataclass


def enum(cls):
    for field_name in dir(cls):
        if field_name.startswith('__') and field_name.endswith('__'): continue
        setattr(cls, field_name, make_dataclass(field_name, list(getattr(cls, field_name).items()), bases=(cls, )))
    return cls