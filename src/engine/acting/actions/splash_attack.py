from src.lib.vector import grid_get, add2, int2
from src.engine.acting.damage import inflict_damage

from dataclasses import dataclass
from ecs import OwnedEntity
from src.engine.acting.action import Action
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.level import Level


@dataclass
class SplashAttack(Action):
    position: int2
    r: int

    def execute(self, actor: OwnedEntity, level: Level, infosphere, hades: Hades, genesis: Genesis):
        for dy in range(-self.r, self.r + 1):
            for dx in range(abs(dy) - self.r, self.r - abs(dy) + 1):
                if (target := grid_get(level.grids.physical, add2(self.position, (dx, dy)))) is not None:
                    inflict_damage(target, actor.weapon, hades)
