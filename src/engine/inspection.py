from ecs import DynamicEntity

from src.lib.query import Q
from src.lib.toolkit import soft_capitalize
from src.systems.ai import classified_as, Kind


def inspect(subject: DynamicEntity) -> {str: str | bool | None}:
    return [(m.__doc__ or "", m(subject)) for m in metrics]


metrics = []

@metrics.append
def name(subject: DynamicEntity) -> str | bool | None:
    prefix = {
        "male": "♂ ",
        "female": "♀ ",
        "mercury": "☿ ",
        None: "",
    }[~Q(subject).sex]

    return f"{prefix}{soft_capitalize(str(~Q(subject).name or ''))}"

@metrics.append
def faction(subject: DynamicEntity) -> str | bool | None:
    """Фракция"""
    return ~Q(subject).faction

@metrics.append
def armor(subject: DynamicEntity) -> str | bool | None:
    """Броня"""
    return ~Q(subject).health.armor_kind

@metrics.append
def hurt(subject: DynamicEntity) -> str | bool | None:
    if (health := ~Q(subject).health) and health.amount.current <= (health.amount.maximum - 1) / 2:
        return "Ранен" if classified_as(subject, Kind.Animate) else "Повреждён"

@metrics.append
def looks_strong(subject: DynamicEntity) -> str | bool | None:
    if (health := ~Q(subject).health) and health.amount.maximum >= 50:
        return {
            None: "Выглядит крепко",
            "female": "Выглядит сильной",
            "male": "Выглядит сильным",
            "mercury": "Выглядит сильно",
        }.get(~Q(subject).sex)
