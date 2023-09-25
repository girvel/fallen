from ecs import DynamicEntity

from src.lib.query import Query
from src.lib.toolkit import from_snake_case


def inspect(subject: DynamicEntity) -> {str: str | bool | None}:
    return {from_snake_case(m.__name__): m(subject) for m in metrics}


metrics = []

@metrics.append
def name(subject: DynamicEntity) -> str | bool | None:
    return ~Query(subject).name

@metrics.append
def sex(subject: DynamicEntity) -> str | bool | None:
    return ~Query(subject).sex

@metrics.append
def faction(subject: DynamicEntity) -> str | bool | None:
    return ~Query(subject).faction

@metrics.append
def hurt(subject: DynamicEntity) -> str | bool | None:
    return (health := ~Query(subject).health) and health.amount.current <= (health.amount.maximum - 1) / 2

@metrics.append
def looks_strong(subject: DynamicEntity) -> str | bool | None:
    return (health := ~Query(subject).health) and health.amount.maximum >= 50
