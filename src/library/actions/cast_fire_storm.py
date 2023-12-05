from dataclasses import dataclass

import numpy
from ecs import Entity
from tcod import tcod

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.library.effects.fire import Fire
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades
from src.lib.vector import grid_get


@dataclass
class CastFireStorm(Action, Aggressive):
    duration: int = 12
    power: int = 3

    def execute(self, actor: Entity, hades: Hades, genesis: Genesis):
        for step in range(self.duration):
            r = (step + 1) * self.power
            fire_map = tcod.map.compute_fov(actor.level.transparency_cache, actor.p, r)

            for p in actor.level.iter_square(actor.p, r):
                if fire_map[p] and grid_get(actor.level.grids["effects"], p) is None:
                    genesis.entities_to_create.add(Fire(half_life=18, heat=25, p=p, level=actor.level, parent=actor))

            yield

    def get_victims(self, actor: Entity) -> list[Entity]:
        r = self.duration * self.power
        fire_map = tcod.map.compute_fov(actor.level.transparency_cache, actor.p, r)

        return [
            victim
            for p in actor.level.iter_square(actor.p, r)
            if fire_map[p] and (victim := grid_get(actor.level.grids["effects"], p)) is not None
        ]

