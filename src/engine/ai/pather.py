import logging

from ecs import OwnedEntity
from rust_enum import Option

import numpy
from tcod.path import Pathfinder, SimpleGraph

from src.engine.acting.actions.move import Move
from src.lib.vector import directions, sub2, map_grid, unsafe_set2, add2, abs2, int2
from src.systems.ai import Perception


class PathTarget(Option[int2]): pass

class Pather:
    going_to = PathTarget.Nothing()

    def __init__(self):
        self.path = []
        self.free_directions = None

    def try_going(self, subject: OwnedEntity, perception: Perception) -> Option[Move]:
        self.free_directions = [
            d for d in directions if perception.vision[subject.layer].get(add2(subject.p, d)) is None
        ]

        if len(self.free_directions) == 0: return Option.Nothing()

        if destination := self.going_to.unwrap_or():
            # Move if there is a path
            if len(self.path) > 0:
                # Reset path if the target is changed
                if self.path[0] != destination:
                    self.path = []
                else:
                    go_to = self.path.pop()
                    if perception.vision[subject.layer].get(go_to) is None:
                        return Option.Some(Move(sub2(go_to, subject.p)))

            # Create grid for calculations, escaping the beginning and the end
            grid = map_grid(subject.spacial_memory, lambda c: c == "." and 1 or 0)
            unsafe_set2(grid, subject.p, 1)
            unsafe_set2(grid, destination, 1)

            # Resort to external library to construct the path
            pathfinder = Pathfinder(SimpleGraph(cost=numpy.array(grid[0]).transpose(), cardinal=1, diagonal=0))
            pathfinder.add_root(subject.p)
            self.path = list(map(tuple, pathfinder.path_to(destination)))[1:][::-1]
            return Option.Nothing()

        return Option.Nothing()