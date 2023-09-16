from ecs import OwnedEntity

from src.engine.ai.attacker import Attacker
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.follower import Follower
from src.engine.ai.morale import Morale
from src.engine.ai.pather import Pather
from src.systems.ai import Perception


class KnightAi(OwnedEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(3)
        self.fight_or_flight = FightOrFlight(True)
        self.attacker = Attacker()
        self.morale = Morale()

    def make_decision(self, subject, perception: Perception):
        self.morale.update(subject, perception)

        if attack := self.attacker.try_attacking(subject, perception, self.fight_or_flight.current_target).unwrap_or():
            return attack

        if path_target := (
            self.fight_or_flight.try_producing_target(subject, perception).unwrap_or() or
            self.follower.try_producing_target(subject, perception).unwrap_or()
        ):
            self.pather.going_to = path_target

        if action := self.pather.try_going(subject, perception).unwrap_or():
            return action
