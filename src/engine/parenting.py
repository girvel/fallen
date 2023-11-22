from ecs import DynamicEntity

from src.lib.query import Q


def has_parent(subject: DynamicEntity, potential_parent: DynamicEntity) -> bool:
    return (
        (parent := ~Q(subject).parent) is not None and
        (parent is potential_parent or has_parent(parent, potential_parent))
    )

def iter_parenting_stack(subject: DynamicEntity):
    yield subject
    if (parent := ~Q(subject).parent) is not None:
        yield from iter_parenting_stack(parent)
