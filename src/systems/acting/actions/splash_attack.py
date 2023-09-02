import logging
from collections import namedtuple

from src.lib.vector import safe_get2, add2
from src.systems.acting.damage import inflict_damage


class SplashAttack(namedtuple("SplashAttackBase", "position, r")):
    def execute(self, actor, level, hades):
        for dy in range(-self.r, self.r + 1):
            for dx in range(abs(dy) - self.r, self.r - abs(dy) + 1):
                if (target := safe_get2(level.grids.physical, add2(self.position, (dx, dy)))) is not None:
                    inflict_damage(target, actor.weapon, hades)
