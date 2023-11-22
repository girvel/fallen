from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import attack
from src.lib.toolkit import rhombus_iterator
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.lib.vector import grid_get, add2, int2


@dataclass
class SplashAttack(Action, Aggressive):
    position: int2
    r: int

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        for dp in rhombus_iterator(self.r):
            if (target := grid_get(actor.level.grids.physical, add2(self.position, dp))) is not None:
                attack(actor, target, hades)

    def get_victims(self, actor: DynamicEntity) -> list[DynamicEntity]:
        return [
            target
            for dp in rhombus_iterator(self.r)
            if (target := grid_get(actor.level.grids.physical, add2(self.position, dp))) is not None
        ]

