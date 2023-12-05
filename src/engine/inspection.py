from ecs import Entity

from src.lib.query import Q
from src.lib.toolkit import soft_capitalize
from src.engine.ai import Kind, classified_as


def inspect(subject: Entity) -> {str: str | bool | None}:
    return [(m.__doc__ or "", m(subject)) for m in metrics]


metrics = []

@metrics.append
def name(subject: Entity) -> str | bool | None:
    prefix = {
        "male": "♂ ",
        "female": "♀ ",
        "mercury": "☿ ",
        None: "",
    }[~Q(subject).sex]

    return f"{prefix}{soft_capitalize(str(~Q(subject).name or ''))}"

@metrics.append
def faction(subject: Entity) -> str | bool | None:
    """Фракция"""
    return ~Q(subject).faction

@metrics.append
def armor(subject: Entity) -> str | bool | None:
    """Броня"""
    return ~Q(subject).health.armor_kind

@metrics.append
def hurt(subject: Entity) -> str | bool | None:
    if (health := ~Q(subject).health) and health.amount.current <= (health.amount.maximum - 1) / 2:
        return "Ранен" if classified_as(subject, Kind.Animate) else "Повреждён"

@metrics.append
def looks_strong(subject: Entity) -> str | bool | None:
    if (health := ~Q(subject).health) and health.amount.maximum >= 50:
        return {
            None: "Выглядит крепко",
            "female": "Выглядит сильной",
            "male": "Выглядит сильным",
            "mercury": "Выглядит сильно",
        }.get(~Q(subject).sex)
