from collections import namedtuple

from ecs import exists

from src.engine.acting.damage import inflict_damage


class Attack(namedtuple("AttackBase", "target")):
    def execute(self, actor, level, hades, genesis):
        if self.target is None or not exists(self.target) or "health" not in self.target: return
        inflict_damage(self.target, actor.weapon, hades)
