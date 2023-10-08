from dataclasses import dataclass

import numpy
from ecs import DynamicEntity
from tcod import tcod

from src.engine.acting.action import Action
from src.entities.effects.fire import Fire
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.lib.vector import grid_get


@dataclass
class CastFireStorm(Action):
    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        for step in range(12):
            r = (step + 1) * 3
            fire_map = tcod.map.compute_fov(actor.level.transparency_cache, actor.p, r)

            for p in actor.level.iter_square(actor.p, r):
                if fire_map[p] and grid_get(actor.level.grids.effects, p) is None:
                    genesis.entities_to_create.add(Fire(half_life=18, heat=25, p=p, level=actor.level))

            yield
