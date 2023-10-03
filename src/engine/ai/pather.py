import numpy
from ecs import DynamicEntity
from rust_enum import Option
from tcod.path import Pathfinder, SimpleGraph

from src.engine.acting.actions.move import Move
from src.engine.ai.spacial_memory import SpacialMemory
from src.lib.vector import directions, sub2, map_grid, grid_set, add2, int2, d2
from src.systems.ai import Perception


class PathTarget(Option[int2]): pass

class Pather:
    going_to = PathTarget.Nothing()

    def __init__(self):
        self.path = []
        self.free_directions = None

    def try_going(self, subject: DynamicEntity, perception: Perception, spacial_memory: SpacialMemory) -> Option[Move]:
        # Update public self.free_directions
        self.free_directions = [
            d for d in directions if perception.vision[subject.layer].get(add2(subject.p, d)) is None
        ]

        # Don't move if there are nowhere to go
        if (
            len(self.free_directions) == 0 or
            not (destination := self.going_to.unwrap_or())
        ):
            return Option.Nothing()

        if (
            destination == subject.p or
            d2(destination, subject.p) == 1 and perception.vision[subject.layer].get(destination) is not None
        ):
            self.going_to = PathTarget.Nothing()
            return Option.Nothing()

        # Try to build path if there isn't one
        if (
            len(self.path) == 0 or
            self.path[0] != destination or
            perception.vision[subject.layer].get(self.path[-1]) is not None
        ):
            # Create grid for calculations, escaping the beginning and the end
            grid = map_grid(spacial_memory[subject.level], lambda c: c == "." and 1 or 0)
            grid_set(grid, subject.p, 1)
            grid_set(grid, destination, 1)

            # Resort to external library to construct the path
            pathfinder = Pathfinder(SimpleGraph(cost=numpy.array(grid[0]).transpose(), cardinal=1, diagonal=0))
            pathfinder.add_root(subject.p)
            self.path = list(map(tuple, pathfinder.path_to(destination)))[1:][::-1]

            # If the generated path is invalid there is no purpose in continuing
            if len(self.path) == 0: return Option.Nothing()

        return Option.Some(Move(sub2(self.path.pop(), subject.p)))
