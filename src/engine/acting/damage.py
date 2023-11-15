import logging
from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity, DynamicEntity

from src.library.special.hades import Hades
from src.lib.limited import Limited
from src.lib.query import Q
from src.lib.toolkit import random_round


@dataclass
class Weapon:
    power: int
    damage_kind: str

@dataclass
class Health:
    amount: Limited
    armor_kind: str
    last_damaged_by: list[DynamicEntity]

    def __init__(self, amount: int, armor_kind: str):
        self.amount = Limited(amount + 1)
        self.armor_kind = armor_kind
        self.last_damaged_by = []


def attack(source: DynamicEntity, target: DynamicEntity, hades: Hades):
    if (weapon := ~Q(source).weapon) is None: return

    return inflict_damage(
        target, potential_damage(source), weapon.damage_kind, hades, source,
    )


def potential_damage(source: DynamicEntity):
    if (skill := ~Q(source).skill) is not None:
        skill_k = skill.get(source.weapon.damage_kind) or .5
    else:
        skill_k = 1

    return source.weapon.power * skill_k


def inflict_damage(
    target: DynamicEntity, power: float, damage_kind: str, hades: Hades, source: DynamicEntity
):
    if (health := ~Q(target).health) is None: return

    armor = armor_data[health.armor_kind]
    if damage_kind in armor.resistance:
        modifier = 0.5
    elif damage_kind in armor.vulnerability:
        modifier = 2
    else:
        modifier = 1

    total_damage = random_round(power * modifier)

    logging.info(
        f"Damage to {target.name}: {total_damage} = {power} * {modifier} ({damage_kind} on {health.armor_kind})"
    )

    health.amount.move(-total_damage)
    health.last_damaged_by.append(source)

    if health.amount.current <= 0:
        logging.info(f"{target.name} is killed")
        hades.entities_to_destroy.add(target)


db = yaml.safe_load((Path(__file__).parent / "damage_and_armor.yaml").read_text())

armor_data = Entity(**{
    armor_kind: Entity(resistance=set(resistance), vulnerability=set(vulnerability))
    for armor_kind, (resistance, vulnerability) in db["armor_kinds"].items()
})

DamageKind = Entity(**{kind: kind for kind in db["damage_kinds"]})
ArmorKind = Entity(**{kind: kind for kind in db["armor_kinds"]})

del db
