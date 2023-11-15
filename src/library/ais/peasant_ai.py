import random
from dataclasses import dataclass, field
from enum import Enum

from src.engine.composite_ai import CompositeAi
from src.lib.period.period import Period
from src.lib.period.random_period import RandomPeriod
from src.lib.toolkit import random_choice_or
from src.lib.typed_dict import TypeDict
from src.lib.vector import directions, add2, grid_get
from src.library.ai_modules.fight_or_flight import FightOrFlight
from src.library.ai_modules.language_center import LanguageCenter
from src.library.ai_modules.morale import Morale
from src.library.ai_modules.observer import Observer
from src.library.ai_modules.pather import Pather
from src.library.ai_modules.spacial_memory import SpacialMemory
from src.library.ai_modules.speaker import Speaker
from src.library.ai_modules.wanderer import Wanderer
from src.library.physical.table import Table
from src.library.special.level import Level


class Mode(Enum):
    GoHome = 0
    GoToTable = 1
    WorkAtTable = 2
    GoOutside = 3
    Wander = 4

class PeasantAi(CompositeAi):
    mode = Mode.GoOutside
    favourite_zones = []

    def __init__(self):
        self.working_period = RandomPeriod(80, 121)
        self.wandering_period = RandomPeriod(40, 56)
        self.lagging_period = RandomPeriod(4, 11)
        self.fight_or_flight_period = Period(5)

        self.composite = TypeDict([
            SpacialMemory(),
            Pather(),
            FightOrFlight(False),
            Morale(),
            Wanderer(),
            Speaker(),
            Observer(),
            LanguageCenter(),
        ])

    # It is possible to extract ModalAi parent/component?
    def _make_decision(self, subject, perception):
        self.use(SpacialMemory)
        if self.lagging_period.step(): return

        ideas, sees_agression = self.use(Observer)
        # TODO NEXT self.use & CompositeAi

        self.use(Morale, ideas)
        self.composite[Speaker].messages.extend(self.use(LanguageCenter, ideas))

        recognizes_danger = (
            (sees_agression and self.fight_or_flight_period.step())
            and (target := self.use(FightOrFlight)) != FightOrFlight.no_change_signal
        )

        if recognizes_danger:
            self.composite[Pather].going_to = target
        else:
            if action := self.use(Speaker): return action

        if action := self.use(Pather, self.composite[SpacialMemory]):
            return action

        return self.peasant_routine(subject, perception)

    def peasant_routine(self, subject, perception):
        match self.mode:
            case Mode.GoHome:
                self.composite[Pather].going_to = subject.house.entrance
                self.mode = Mode.GoToTable

            case Mode.GoToTable:
                randomized_directions = directions[:]
                random.shuffle(randomized_directions)

                spacial_memory = self.composite[SpacialMemory][subject.level]

                if ((destination := random_choice_or([
                    free_space
                    for x in range(subject.house.house_borders[0][0], subject.house.house_borders[1][0])
                    for y in range(subject.house.house_borders[0][1], subject.house.house_borders[1][1])
                    if grid_get(spacial_memory, (table_p := (x, y))) == Table.character
                    and (free_space := next((
                        p
                        for d in directions
                        if grid_get(spacial_memory, (p := add2(table_p, d))) == Level.no_entity_character
                    ), None))  # TODO and Pather.available
                ])) is not None):
                    self.composite[Pather].going_to = destination
                    self.mode = Mode.WorkAtTable
                else:
                    self.mode = Mode.GoOutside

            case Mode.WorkAtTable:
                if self.working_period.step():
                    self.mode = Mode.GoOutside

            case Mode.GoOutside:
                self.composite[Pather].going_to = random.choices(
                    self.favourite_zones,
                    [zone.attractiveness for zone in self.favourite_zones]
                )[0].center

                self.mode = Mode.Wander

            case Mode.Wander:
                if not self.wandering_period.step():
                    return self.use(Wanderer, self.composite[Pather].free_directions)

                self.mode = Mode.GoHome
