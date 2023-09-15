from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity, OwnedEntity

import logging

from src.lib.limited import Limited


@dataclass
class Weapon:
    power: int
    damage_kind: str

@dataclass
class Health:
    amount: Limited
    armor_kind: str

    def __init__(self, amount: int, armor_kind: str):
        self.amount = Limited(amount + 1)
        self.armor_kind = armor_kind


def inflict_damage(target: OwnedEntity, weapon: Weapon, hades: OwnedEntity):
    if "health" not in target: return

    armor = armor_data[target.health.armor_kind]
    if weapon.damage_kind in armor.resistance:
        modifier = 0.5
    elif weapon.damage_kind in armor.vulnerability:
        modifier = 2
    else:
        modifier = 1

    logging.info(
        f"{target.name} is damaged w/ {weapon.power} * {modifier} "
        f"({weapon.damage_kind} on {target.health.armor_kind})"
    )

    target.health.amount.move(-weapon.power * modifier)
    target.receives_damage = True

    if target.health.amount.current <= 0:
        logging.info(f"{target.name} is killed")
        hades.entities_to_destroy.append(target)


db = yaml.safe_load(Path("assets/damage_and_armor.yaml").read_text())

armor_data = Entity(**{
    armor_kind: Entity(resistance=set(resistance), vulnerability=set(vulnerability))
    for armor_kind, (resistance, vulnerability) in db["armor_kinds"].items()
})

DamageKind = Entity(**{kind: kind for kind in db["damage_kinds"]})
ArmorKind = Entity(**{kind: kind for kind in db["armor_kinds"]})

del db
