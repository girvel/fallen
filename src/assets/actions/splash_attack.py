from dataclasses import dataclass

from src.components import Genesis, Hades
from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import try_inflict_damage
from src.lib.vector.grid import grid_unsafe_get
from src.lib.vector.iteration import iter_rhombus
from src.lib.vector.vector import int2


@dataclass
class SplashAttack(Aggressive, Action):
    p: int2
    r: int
    power: int

    def execute(self, actor, hades: Hades, genesis: Genesis):
        for p in iter_rhombus(self.p, self.r, actor.level.size):
            try_inflict_damage(actor, grid_unsafe_get(actor.level.grids["physical"], p), self.power, hades)

    def get_victims(self, actor) -> list:
        return [
            target
            for p in iter_rhombus(self.p, self.r, actor.level.size)
            if (target := grid_unsafe_get(actor.level.grids["physical"], p)) is not None
        ]
