import numpy
from tcod.path import Pathfinder, SimpleGraph

from src.engine.acting.actions.move import Move
from src.lib.vector import directions, sub2, map_grid, unsafe_set2, add2, abs2


class Pather:
    going_to = None

    def __init__(self):
        self.path = []
        self.free_directions = None

    def try_going(self, subject, perception):
        self.free_directions = [d for d in directions if perception.vision[subject.layer].get(add2(subject.p, d)) is None]
        if len(self.free_directions) == 0: return

        if self.going_to is not None:
            if len(self.path) > 0:
                go_to = self.path.pop()
                if perception.vision[subject.layer].get(go_to) is None:
                    return Move(sub2(go_to, subject.p))

            if abs2(sub2(self.going_to, subject.p)) <= 1:  # path never contains the destination in the middle
                self.going_to = None
                return

            grid = map_grid(subject.spacial_memory, lambda c: c == "." and 1 or 0)
            unsafe_set2(grid, subject.p, 1)
            unsafe_set2(grid, self.going_to, 1)

            pathfinder = Pathfinder(SimpleGraph(cost=numpy.array(grid[0]).transpose(), cardinal=1, diagonal=0))
            pathfinder.add_root(subject.p)
            self.path = list(map(tuple, pathfinder.path_to(self.going_to)))[1:][::-1]
            return