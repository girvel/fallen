from ecs import OwnedEntity

from src.lib.query import Query
from src.lib.toolkit import from_snake_case


def inspect(subject: OwnedEntity) -> {str: str | bool | None}:
    return {from_snake_case(m.__name__): m(subject) for m in metrics}


metrics = []

@metrics.append
def name(subject: OwnedEntity) -> str | bool | None:
    return ~Query(subject).name

@metrics.append
def sex(subject: OwnedEntity) -> str | bool | None:
    return ~Query(subject).sex

@metrics.append
def faction(subject: OwnedEntity) -> str | bool | None:
    return ~Query(subject).faction

@metrics.append
def hurt(subject: OwnedEntity) -> str | bool | None:
    return (health := ~Query(subject).health) and health.amount.current <= (health.amount.maximum - 1) / 2

@metrics.append
def looks_strong(subject: OwnedEntity) -> str | bool | None:
    return (health := ~Query(subject).health) and health.amount.maximum >= 50
