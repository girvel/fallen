import logging
import random
from enum import Enum

from src.engine.acting.actions.move import Move
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.pather import Pather, PathTarget
from src.entities.physical.table import Table
from src.lib.period.period import Period
from src.lib.period.random_period import RandomPeriod
from src.lib.vector import directions, add2, grid_get


Mode = Enum("Mode", "GoHome GoToTable WorkAtTable GoOutside Wandering")

class PeasantAi:
    mode = Mode.GoOutside
    favourite_zones = []

    def __init__(self):
        self.working_period = RandomPeriod(30, 46)
        self.wandering_period = RandomPeriod(20, 36)
        self.lagging_period = RandomPeriod(4, 11)
        self.pather = Pather()
        self.fight_or_flight = FightOrFlight(False)
        self.fight_or_flight_period = Period(5)

    # It is possible to extract ModalAi parent/component?
    def make_decision(self, subject, perception):
        if self.lagging_period.step(): return

        if (
            self.fight_or_flight_period.step()
            and (target := self.fight_or_flight.try_producing_target(subject, perception).unwrap_or())
        ):
            self.pather.going_to = target

        if action := self.pather.try_going(subject, perception).unwrap_or(): return action

        match self.mode:
            case Mode.GoHome:
                self.pather.going_to = PathTarget.Some(subject.house.entrance)
                self.mode = Mode.GoToTable

            case Mode.GoToTable:
                randomized_directions = directions[:]
                random.shuffle(randomized_directions)

                if (
                    (table_p := random.choice([
                        (x, y)
                        for x in range(subject.house.house_borders[0][0], subject.house.house_borders[1][0])
                        for y in range(subject.house.house_borders[0][1], subject.house.house_borders[1][1])
                        if grid_get(subject.spacial_memory, (x, y)) == Table.character
                    ])) is not None
                    and
                    (destination := next((
                        p for v in directions
                        if (p := add2(table_p, v)) and grid_get(subject.spacial_memory, p) == "."
                        # TODO remove magic character
                    ), None)) is not None
                ):
                    self.pather.going_to = PathTarget.Some(destination)
                    self.mode = Mode.WorkAtTable
                else:
                    self.mode = Mode.GoOutside

            case Mode.WorkAtTable:
                if self.working_period.step():
                    self.mode = Mode.GoOutside

            case Mode.GoOutside:
                self.pather.going_to = PathTarget.Some(random.choices(
                    self.favourite_zones,
                    [zone.attractiveness for zone in self.favourite_zones]
                )[0].center)

                self.mode = Mode.Wandering

            case Mode.Wandering:
                if not self.wandering_period.step():
                    if len(self.pather.free_directions) > 0:
                        return Move(random.choice(self.pather.free_directions))
                    return

                self.mode = Mode.GoHome
