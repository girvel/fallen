import numpy
from tcod.path import Pathfinder, SimpleGraph

from src.engine.ai import Perception
from src.lib.vector.vector import directions, sub2, add2, int2, d2
from src.assets.actions.move import Move
from src.assets.ai_modules.spacial_memory import PathMemory


class Pather:
    going_to: int2 | None = None

    def __init__(self):
        self.path = []
        self.free_directions = None

    def use(self, subject, perception: Perception, path_memory: PathMemory) -> Move | None:
        # Update public self.free_directions
        self.free_directions = [
            d for d in directions if perception.vision[subject.layer].get(add2(subject.p, d)) is None
        ]

        # Don't move if there are nowhere to go
        if len(self.free_directions) == 0 or self.going_to is None:
            return None

        if (
            self.going_to == subject.p or
            d2(self.going_to, subject.p) == 1 and perception.vision[subject.layer].get(self.going_to) is not None
        ):
            self.going_to = None
            return None

        # Try to build path if there isn't one
        if (
            len(self.path) == 0 or
            self.path[0] != self.going_to or
            (subject.act and not subject.act.succeeded) or
            perception.vision[subject.layer].get(self.path[-1]) is not None
        ):
            # Create grid for calculations, escaping the beginning and the end
            grid = numpy.array(path_memory[subject.level][0]).transpose()

            for p, effect in perception.vision["effects"].items():  # TODO move to PathMemory???
                if effect is not None:
                    grid[p] = 0

            grid[subject.p] = 1
            grid[self.going_to] = 1

            # Resort to external library to construct the path
            pathfinder = Pathfinder(SimpleGraph(cost=grid, cardinal=1, diagonal=0))
            pathfinder.add_root(subject.p)
            self.path = list(map(tuple, pathfinder.path_to(self.going_to)))[1:][::-1]

            # If the generated path is invalid there is no purpose in continuing
            if len(self.path) == 0: return None

        return Move(sub2(self.path.pop(), subject.p))
