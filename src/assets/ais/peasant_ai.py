import logging
import random

from src.assets.ai_modules.fight_or_flight import FightOrFlight
from src.assets.ai_modules.language_center import LanguageCenter
from src.assets.ai_modules.listener import Listener
from src.assets.ai_modules.morale import Morale
from src.assets.ai_modules.observer import Observer
from src.assets.ai_modules.pather import Pather
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ai_modules.speaker import Speaker
from src.assets.ai_modules.wanderer import Wanderer
from src.lib.limited import Limited
from src.lib.period.random_period import RandomPeriod
from src.lib.time import Time
from src.lib.toolkit import chance, logged


class PeasantAi:
    def __init__(self):
        # TODO NEXT extract timetable logic
        self.timetable = (
            (Time(1), self.wander),
            (Time(3), self.sleep),
            (Time(7), self.wander),
            (Time(8), self.work),
            (Time(13), self.socialize),
            (Time(15), self.work),
            (Time(20), self.socialize),
            (Time(21), self.sleep),
        )
        self.current_row_i = 0
        self.was_mode_switched = True

        self.lagging_period = RandomPeriod(4, 11)
        self.wandering_pause = RandomPeriod(2, 5)

        self.remains_in_danger_mode_for = Limited(15, 0, 0)

        self.pather = Pather()
        self.path_memory = PathMemory()
        self.fight_or_flight = FightOrFlight(False)
        self.morale = Morale()
        self.wanderer = Wanderer()
        self.speaker = Speaker()
        self.observer = Observer()
        self.language_center = LanguageCenter()
        self.listener = Listener()

    def after_creation(self, subject):
        self.path_memory.knows(subject.level)

    def make_decision(self, subject, perception):
        if chance(.3): self.path_memory.use(subject, perception)

        if self.lagging_period.step(): return

        ideas, notices_danger = self.observer.use(subject, perception)

        if notices_danger:
            if self.remains_in_danger_mode_for.is_min():
                logging.info(f"{subject.name} goes to danger mode")
            self.remains_in_danger_mode_for.reset_to_max()
            subject.attention_boost = 10  # TODO maybe boost attention on any Aggression meme?

        if not self.remains_in_danger_mode_for.is_min():
            self.remains_in_danger_mode_for.move(-1)

            if (target := self.fight_or_flight.use(subject, perception)) != FightOrFlight.no_change_signal:
                self.pather.going_to = target  # TODO FightOrFlight meme

            if (move := self.pather.use(subject, perception, self.path_memory)) is not None: return move

            if subject.house is not None and subject.p != subject.house.entrance:
                self.pather.going_to = subject.house.entrance

            return None

        ideas.extend(self.listener.use(subject, perception))

        self.morale.use(subject, perception, ideas)
        self.speaker.messages.extend(self.language_center.use(subject, perception, ideas))

        if action := self.speaker.use(subject, perception): return action
        if action := self.pather.use(subject, perception, self.path_memory): return action

        # TODO NEXT extract timetable logic
        next_i = (self.current_row_i + 1) % len(self.timetable)

        if next_i == 0:
            self.was_mode_switched = (
                subject.level.time.total_seconds > self.timetable[next_i][0].total_seconds
                and subject.level.time.total_seconds < self.timetable[next_i + 1][0].total_seconds
            )
        else:
            self.was_mode_switched = subject.level.time.total_seconds > self.timetable[next_i][0].total_seconds

        if self.was_mode_switched:
            self.current_row_i = next_i
            logging.debug([self.timetable[self.current_row_i][1].__name__, subject.level.time])

        return self.timetable[self.current_row_i][1](subject, perception)

    def sleep(self, subject, _perception):
        if subject.p != subject.bed_p:
            self.pather.going_to = subject.bed_p
            logging.debug(f"sleep: {self.pather.going_to = }")

    def wander(self, subject, perception):
        if self.was_mode_switched:
            self.pather.going_to = random.choices(*zip(*(
                (zone, zone.attractiveness) for zone in subject.level.markup.zones
            )))[0].center
            logging.debug(f"wander: {self.pather.going_to = }")
            return

        if self.wandering_pause.step():
            self.pather.going_to = random.choice(list(iter(perception.vision["physical"])))

    def socialize(self, subject, perception):
        pass

    def work(self, subject, perception):
        pass
