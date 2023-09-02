import random
from enum import Enum

from src.entities.ais.components.pather import Pather
from src.entities.physical.table import Table
from src.lib.period.random_period import RandomPeriod
from src.lib.vector import directions, add2, safe_get2
from src.systems.acting.actions.move import Move



Mode = Enum("Mode", "GoHome GoToTable WorkAtTable GoOutside Wandering")


class PeasantAi:
    going_to = None
    working_period = RandomPeriod(30, 46)
    wandering_period = RandomPeriod(20, 36)
    mode = Mode.GoOutside
    favourite_zones = []

    def __init__(self):
        self.pather = Pather()

    # It is possible to extract ModalAi parent/component?
    def make_decision(self, subject, perception):
        if action := self.pather.go(subject, perception): return action

        match self.mode:
            case Mode.GoHome:
                self.pather.going_to = subject.house.entrance
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
                    self.pather.going_to = destination
                    self.mode = Mode.WorkAtTable
                else:
                    self.mode = Mode.GoOutside

            case Mode.WorkAtTable:
                if self.working_period.step():
                    self.mode = Mode.GoOutside

            case Mode.GoOutside:
                self.pather.going_to = random.choices(
                    self.favourite_zones,
                    [zone.attractiveness for zone in self.favourite_zones]
                )[0].center

                self.mode = Mode.Wandering

            case Mode.Wandering:
                if not self.wandering_period.step():
                    return Move(random.choice(self.pather.free_directions))
                self.mode = Mode.GoHome
