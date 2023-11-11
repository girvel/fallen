import random
from enum import Enum

from src.engine.acting.actions.say import Say
from src.engine.ai.speaker import Speaker
from src.entities.special.level import Level
from src.lib.typed_dict import TypeDict
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.morale import Morale
from src.engine.ai.pather import Pather
from src.engine.ai.spacial_memory import SpacialMemory
from src.engine.ai.wanderer import Wanderer
from src.engine.meme import Meme, MoraleChange
from src.entities.physical.table import Table
from src.lib.period.period import Period
from src.lib.period.random_period import RandomPeriod
from src.lib.query import Q
from src.lib.vector import directions, add2, grid_get

Mode = Enum("Mode", "GoHome GoToTable WorkAtTable GoOutside Wandering")

class PeasantAi:
    mode = Mode.GoOutside
    favourite_zones = []

    def __init__(self):
        self.working_period = RandomPeriod(30, 46)
        self.wandering_period = RandomPeriod(20, 36)
        self.lagging_period = RandomPeriod(4, 11)
        self.fight_or_flight_period = Period(5)
        self.chat_period = RandomPeriod(5, 11)

        self.composite = TypeDict([
            SpacialMemory(),
            Pather(),
            FightOrFlight(False),
            Morale(),
            Wanderer(),
            Speaker(),
        ])

    # It is possible to extract ModalAi parent/component?
    def make_decision(self, subject, perception):
        self.composite[SpacialMemory].use(subject, perception)
        if self.lagging_period.step(): return

        aggressors = self.composite[Morale].use(subject, perception)

        for e, offset in aggressors:
            self.composite[Speaker].messages.append(
                Say(f"<Выражает недовольство {e.name:тв}>", meme=MoraleChange(e, offset))
            )

        if (
            (len(aggressors) > 0 or self.fight_or_flight_period.step())
            and (target := self.composite[FightOrFlight].use(subject, perception)) != FightOrFlight.no_change_signal
        ):
            self.composite[Pather].going_to = target

        if action := self.composite[Pather].use(subject, perception, self.composite[SpacialMemory]):
            return action

        if action := self.composite[Speaker].use(subject, perception): return action

        match self.mode:
            case Mode.GoHome:
                self.composite[Pather].going_to = subject.house.entrance
                self.mode = Mode.GoToTable

            case Mode.GoToTable:
                randomized_directions = directions[:]
                random.shuffle(randomized_directions)

                if (
                    (table_p := random.choice([
                        (x, y)
                        for x in range(subject.house.house_borders[0][0], subject.house.house_borders[1][0])
                        for y in range(subject.house.house_borders[0][1], subject.house.house_borders[1][1])
                        if grid_get(self.composite[SpacialMemory][subject.level], (x, y)) == Table.character
                    ])) is not None
                    and
                    (destination := next((
                        p for v in directions
                        if (p := add2(table_p, v))
                        and grid_get(self.composite[SpacialMemory][subject.level], p) == Level.no_entity_character
                    ), None)) is not None
                ):
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

                self.mode = Mode.Wandering

            case Mode.Wandering:
                if not self.wandering_period.step():
                    return self.composite[Wanderer].use(subject, perception, self.composite[Pather].free_directions)

                self.mode = Mode.GoHome
