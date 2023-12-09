from dataclasses import dataclass

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import attack
from src.lib.vector.grid import grid_unsafe_get
from src.lib.vector.iteration import iter_rhombus
from src.lib.vector.vector import int2
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class SplashAttack(Action, Aggressive):
    p: int2
    r: int

    def execute(self, actor, hades: Hades, genesis: Genesis):
        for p in iter_rhombus(self.p, self.r, actor.level.size):
            if (target := grid_unsafe_get(actor.level.grids["physical"], p)) is not None:
                attack(actor, target, hades)

    def get_victims(self, actor) -> list:
        return [
            target
            for p in iter_rhombus(self.p, self.r, actor.level.size)
            if (target := grid_unsafe_get(actor.level.grids["physical"], p)) is not None
        ]

