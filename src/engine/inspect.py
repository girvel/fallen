from ecs import DynamicEntity

from src.lib.query import Q
from src.lib.toolkit import from_snake_case


def inspect(subject: DynamicEntity) -> {str: str | bool | None}:
    return {from_snake_case(m.__name__): m(subject) for m in metrics}


metrics = []

@metrics.append
def _(subject: DynamicEntity) -> str | bool | None:
    return {
        "male": "♂ ",
        "female": "♀ ",
        "mercury": "☿ ",
        None: "",
    }[~Q(subject).sex] + ~Q(subject).name or ""

@metrics.append
def faction(subject: DynamicEntity) -> str | bool | None:
    return ~Q(subject).faction

@metrics.append
def armor(subject: DynamicEntity) -> str | bool | None:
    return ~Q(subject).health.armor_kind

@metrics.append
def hurt(subject: DynamicEntity) -> str | bool | None:
    return (health := ~Q(subject).health) and health.amount.current <= (health.amount.maximum - 1) / 2

@metrics.append
def looks_strong(subject: DynamicEntity) -> str | bool | None:
    return (health := ~Q(subject).health) and health.amount.maximum >= 50
