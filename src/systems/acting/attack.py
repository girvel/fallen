from collections import namedtuple
from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity

import logging

log = logging.getLogger(__name__)


class Attack(namedtuple("AttackBase", "target")):
    def execute(self, actor, level, hades):
        actor.act = None

        if self.target is None or "health" not in self.target: return

        armor = armor_data[self.target.health.armor_kind]
        if actor.weapon.damage_kind in armor.resistance:
            modifier = 0.5
        elif actor.weapon.damage_kind in armor.vulnerability:
            modifier = 2
        else:
            modifier = 1

        log.info(
            f"{actor.name} damages {self.target.name} w/ {actor.weapon.power} * {modifier} "
            f"({actor.weapon.damage_kind} on {self.target.health.armor_kind})"
        )

        self.target.health.value -= actor.weapon.power * modifier
        self.target.receives_damage = True
        if self.target.health.value <= 0:
            log.info(f"{actor.name} kills {self.target.name}")
            hades.entities_to_destroy.append(self.target)


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
