from collections import namedtuple
from dataclasses import dataclass
from pathlib import Path

import yaml
from ecs import Entity


class Attack(namedtuple("AttackBase", "v")):
    def execute(self, actor, level, hades):
        actor.act = None

        next_p = actor.p + self.v
        if next_p.get_in(level.level_grid) is None: return

        enemy = next_p.get_in(level.level_grid)

        if "health" not in enemy: return

        armor = armor_data[enemy.health.armor_kind]
        if actor.weapon.damage_kind in armor.resistance:
            modifier = 0.5
        elif actor.weapon.damage_kind in armor.vulnerability:
            modifier = 2
        else:
            modifier = 1

        enemy.health.value -= actor.weapon.power * modifier
        enemy.receives_damage = True
        if enemy.health.value <= 0:
            hades.entities_to_destroy.append(enemy)


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
