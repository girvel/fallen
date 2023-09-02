import random
from enum import Enum

import numpy

from src.entities.physical.table import Table
from src.lib.period.random_period import RandomPeriod
from src.lib.vector import directions, add2, sub2, map_grid, unsafe_set2, safe_get2
from src.systems.acting.actions.move import Move

from tcod.path import Pathfinder, SimpleGraph

import logging

log = logging.getLogger(__name__)


Mode = Enum("Mode", "GoHome GoToTable WorkAtTable GoOutside Wandering")


class PeasantAi:
    going_to = None
    working_period = RandomPeriod(30, 46)
    wandering_period = RandomPeriod(20, 36)
    mode = Mode.GoOutside
    favourite_zones = []

    def __init__(self):
        self.path = []

    # It is possible to extract ModalAi parent
    def make_decision(self, subject, perception):
        free_directions = [d for d in directions if perception.vision.get(add2(subject.p, d)) is None]
        if len(free_directions) == 0: return

        if self.going_to is not None:
            if len(self.path) > 0:
                go_to = self.path.pop()
                if perception.vision.get(go_to) is None:
                    return Move(sub2(go_to, subject.p))

            if self.going_to == subject.p:  # path never contains the destination in the middle
                self.going_to = None
                return

            grid = map_grid(subject.spacial_memory, lambda c: c == "." and 1 or 0)
            unsafe_set2(grid, subject.p, 1)

            pathfinder = Pathfinder(SimpleGraph(cost=numpy.array(grid[0]).transpose(), cardinal=1, diagonal=0))
            pathfinder.add_root(subject.p)
            self.path = list(map(tuple, pathfinder.path_to(self.going_to)))[1:][::-1]
            return

        match self.mode:
            case Mode.GoHome:
                self.going_to = subject.house.entrance
                self.mode = Mode.GoToTable

            case Mode.GoToTable:
                randomized_directions = directions[:]
                random.shuffle(randomized_directions)

                if (
                    (table_p := random.choice([
                        (x, y)
                        for x in range(subject.house.house_borders[0][0], subject.house.house_borders[1][0])
                        for y in range(subject.house.house_borders[0][1], subject.house.house_borders[1][1])
                        if safe_get2(subject.spacial_memory, (x, y)) == Table.character
                    ])) is not None
                    and
                    (destination := next((
                        p for v in directions
                        if (p := add2(table_p, v)) and safe_get2(subject.spacial_memory, p) == "."
                        # TODO remove magic character
                    ), None)) is not None
                ):
                    self.going_to = destination
                    self.mode = Mode.WorkAtTable
                else:
                    self.mode = Mode.GoOutside

            case Mode.WorkAtTable:
                if self.working_period.step():
                    self.mode = Mode.GoOutside

            case Mode.GoOutside:
                self.going_to = random.choice(self.favourite_zones).center
                self.mode = Mode.Wandering

            case Mode.Wandering:
                if not self.wandering_period.step():
                    return Move(random.choice(free_directions))
                self.mode = Mode.GoHome
