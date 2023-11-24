import random
from enum import Enum

from src.engine.composite_ai import CompositeAi
from src.lib.limited import Limited
from src.lib.period.random_period import RandomPeriod
from src.lib.toolkit import random_choice_or
from src.lib.typed_dict import TypeDict
from src.lib.vector import directions, add2, grid_get
from src.library.ai_modules.fight_or_flight import FightOrFlight
from src.library.ai_modules.language_center import LanguageCenter
from src.library.ai_modules.listener import Listener
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

    def __init__(self):
        self.working_period = RandomPeriod(80, 121)
        self.wandering_period = RandomPeriod(40, 56)
        self.lagging_period = RandomPeriod(4, 11)

        self.remains_in_danger_mode_for = Limited(15, 0, 0)

        self.composite = TypeDict([
            SpacialMemory(),
            Pather(),
            FightOrFlight(False),
            Morale(),
            Wanderer(),
            Speaker(),
            Observer(),
            LanguageCenter(),
            Listener(),
        ])

    # It is possible to extract ModalAi parent/component?
    def _make_decision(self, subject, perception):
        self.use(SpacialMemory)
        if self.lagging_period.step(): return

        ideas, notices_danger = self.use(Observer)
        if notices_danger: self.remains_in_danger_mode_for.reset_to_max()

        if not self.remains_in_danger_mode_for.is_min():
            self.remains_in_danger_mode_for.move(-1)

            if (target := self.use(FightOrFlight)) != FightOrFlight.no_change_signal:
                self.composite[Pather].going_to = target
            # TODO NEXT change mode to go home
            # TODO NEXT get away module

            return self.use(Pather, self.composite[SpacialMemory])

        ideas.extend(self.use(Listener))

        self.use(Morale, ideas)
        self.composite[Speaker].messages.extend(self.use(LanguageCenter, ideas))

        if action := self.use(Speaker): return action

        if action := self.use(Pather, self.composite[SpacialMemory]):
            return action

        return self.peasant_routine(subject, perception)

    def peasant_routine(self, subject, perception):
        if subject.house is None and self.mode in (Mode.GoHome, Mode.GoToTable, Mode.WorkAtTable):
            self.mode = Mode.Wander

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
                if len(subject.level.markup.zones) > 0:
                    self.composite[Pather].going_to = random.choices(*zip(*(
                        (zone, zone.attractiveness) for zone in subject.level.markup.zones
                    )))[0].center

                self.mode = Mode.Wander

            case Mode.Wander:
                if not self.wandering_period.step():
                    return self.use(Wanderer, self.composite[Pather].free_directions)

                self.mode = Mode.GoHome
