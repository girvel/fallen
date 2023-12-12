import logging
from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity

from src.engine.parenting import iter_parenting_stack
from src.lib.limited import Limited
from src.lib.query import Q
from src.lib.toolkit import random_round
from src.library.special.hades import Hades


@dataclass
class Weapon:
    power: int
    damage_kind: str

@dataclass
class Health:
    amount: Limited
    armor_kind: str
    last_damaged_by: list[Entity]

    def __init__(self, amount: int, armor_kind: str):
        self.amount = Limited(amount + 1)
        self.armor_kind = armor_kind
        self.last_damaged_by = []


def attack(source: Entity, target: Entity, hades: Hades):
    if (weapon := ~Q(source).weapon) is None: return

    return inflict_damage(
        target, potential_damage(source), weapon.damage_kind, hades, source,
    )


def potential_damage(source) -> int:
    if (skill := ~Q(source).skill) is not None:
        skill_k = skill.get(source.weapon.damage_kind) or .5
    else:
        skill_k = 1

    return source.weapon.power * skill_k


def inflict_damage(
    target, power: float, damage_kind: str, hades: Hades, source: Entity
):
    if (health := ~Q(target).health) is None: return

    if damage_kind in health.armor_kind.resistance:
        modifier = 0.5
    elif damage_kind in health.armor_kind.vulnerability:
        modifier = 2
    else:
        modifier = 1

    total_damage = random_round(power * modifier)

    if not hasattr(target, "boring_flag"):
        logging.info(
            f"Damage to {target.name}: {total_damage} = {power} * {modifier} ({damage_kind} on {health.armor_kind})"
        )

    health.amount.move(-total_damage)
    health.last_damaged_by.append(source)

    if health.amount.current <= 0:
        logging.info(f"{target.name} is killed")
        hades.entities_to_destroy.add(target)

        for killer in iter_parenting_stack(source):
            if not hasattr(killer, "last_killed"):
                killer.last_killed = []

            killer.last_killed.append(target)
