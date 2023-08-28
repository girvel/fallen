import logging
import random
import sys
from enum import Enum
from pathlib import Path

import numpy

from src.lib.period.random_period import RandomPeriod
from src.lib.vector import directions, add2, floordiv2, sub2, map_grid, unsafe_set2
from src.systems.acting.actions.move import Move

from tcod.path import Pathfinder, SimpleGraph


class Mode(Enum):
    # Wandering = 0
    # GoHome = 1
    GoHome = 0


class PeasantAi:
    decision_period = RandomPeriod(2, 4)
    mode_period = RandomPeriod(10, 26)
    spacial_memory = None

    def __init__(self):
        self.mode = Mode(random.randrange(len(Mode)))
        self.path = []

    def make_decision(self, subject, perception):
        if len(self.path) > 0:
            logging.debug(self.path)
            go_to = self.path.pop()
            if perception.vision.get(go_to) is None:
                return Move(sub2(go_to, subject.p))

            self.path = []

        decision_step = self.decision_period.step()
        if decision_step == 0: return

        free_directions = [d for d in directions if perception.vision.get(add2(subject.p, d)) is None]
        if len(free_directions) == 0: return

        if self.mode_period.step(decision_step):
            self.mode = Mode((self.mode.value + 1) % len(Mode))

        match self.mode:
            # case Mode.Wandering:
            #     return Move(random.choice(free_directions))
            case Mode.GoHome:
                # based_center = floordiv2(perception.free_cache.shape, 2)
                # r = based_center[0]
                # base = sub2(subject.p, based_center)
                #
                # if subject.house.entrance in perception.vision:
                #     target = subject.house.entrance
                # else:
                #     target = subject.p
                #     current_target = target
                #     v = sign2(sub2(subject.house.entrance, subject.p))
                #
                #     dx, dy = sub2(subject.house.entrance, base)
                #     for _ in range(max(abs(dx), abs(dy))):
                #         current_target = add2(current_target, v)
                #
                #         if current_target not in perception.vision:
                #             break
                #
                #         if perception.vision.get(current_target) is not None:
                #             continue

                grid = map_grid(self.spacial_memory, lambda c: c == "." and 1 or 0)
                unsafe_set2(grid, subject.p, 1)
                pathfinder = Pathfinder(SimpleGraph(
                    cost=numpy.array(grid[0]).transpose(), cardinal=1, diagonal=0
                ))

                pathfinder.add_root(subject.p)
                self.path = list(map(tuple, pathfinder.path_to(subject.house.entrance)))[1:][::-1]
