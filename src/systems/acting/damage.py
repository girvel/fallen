from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity

import logging

log = logging.getLogger(__name__)


def inflict_damage(target, weapon, hades):
    armor = armor_data[target.health.armor_kind]
    if weapon.damage_kind in armor.resistance:
        modifier = 0.5
    elif weapon.damage_kind in armor.vulnerability:
        modifier = 2
    else:
        modifier = 1

    log.info(
        f"{target.name} is damaged w/ {weapon.power} * {modifier} "
        f"({weapon.damage_kind} on {target.health.armor_kind})"
    )

    target.health.value -= weapon.power * modifier
    target.receives_damage = True
    if target.health.value <= 0:
        log.info(f"{target.name} is killed")
        hades.entities_to_destroy.append(target)


@dataclass
class Weapon:
    power: int
    damage_kind: str

@dataclass
class Health:
    value: int
    armor_kind: str


db = yaml.safe_load(Path("assets/damage_and_armor.yaml").read_text())

armor_data = Entity(**{
    armor_kind: Entity(resistance=set(resistance), vulnerability=set(vulnerability))
    for armor_kind, (resistance, vulnerability) in db["armor_kinds"].items()
})

DamageKind = Entity(**{kind: kind for kind in db["damage_kinds"]})
ArmorKind = Entity(**{kind: kind for kind in db["armor_kinds"]})

del db
