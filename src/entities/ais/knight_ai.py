from ecs import OwnedEntity

from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather


class KnightAi(OwnedEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(3)
        self.fight_or_flight = FightOrFlight(True)

    def make_decision(self, subject, perception):
        if p := (
            self.fight_or_flight.try_producing_target(subject, perception).unwrap_or() or
            self.follower.try_producing_target(subject, perception).unwrap_or()
        ):
            self.pather.going_to = p

        if action := self.pather.try_going(subject, perception):
            return action
