from dataclasses import dataclass

from ecs import Entity
from tcod import tcod

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.lib.vector.iteration import iter_square
from src.assets.effects.fire import Fire
from src.components import Genesis, Hades
from src.lib.vector.grid import grid_get


@dataclass
class CastFireStorm(Aggressive, Action):
    duration: int = 12
    power: int = 3

    def execute(self, actor, hades: Hades, genesis: Genesis):
        for step in range(self.duration):
            r = (step + 1) * self.power
            fire_map = tcod.map.compute_fov(actor.level.transparency_cache, actor.p, r)

            for p in iter_square(actor.p, r, actor.level.size):
                if fire_map[p] and grid_get(actor.level.grids["effects"], p) is None:
                    genesis.push(Fire(half_life=18, heat=25, p=p, level=actor.level, parent=actor))

            yield

    def get_victims(self, actor) -> list:
        r = self.duration * self.power
        fire_map = tcod.map.compute_fov(actor.level.transparency_cache, actor.p, r)

        return [
            victim
            for p in iter_square(actor.p, r, actor.level.size)
            if fire_map[p] and (victim := grid_get(actor.level.grids["effects"], p)) is not None
        ]

