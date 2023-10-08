from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.acting.damage import attack
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.vector import grid_get, add2, int2


@dataclass
class SplashAttack(Action):
    position: int2
    r: int

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        for dy in range(-self.r, self.r + 1):
            for dx in range(abs(dy) - self.r, self.r - abs(dy) + 1):
                if (target := grid_get(actor.level.grids.physical, add2(self.position, (dx, dy)))) is not None:
                    attack(actor, target, hades)
