import logging

from ecs import OwnedEntity

from src.engine.acting.actions.attack import Attack
from src.engine.ai.attacker import Attacker
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather
from src.engine.reputation import move_demeanor_towards, demeanor_towards
from src.systems.ai import Perception


class KnightAi(OwnedEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(3)
        self.fight_or_flight = FightOrFlight(True)
        self.attacker = Attacker()

    def make_decision(self, subject, perception: Perception):
        aggressives = [
            e for e in perception.vision.physical.values()
            if hasattr(e, "act")
            and hasattr(e.act, "target")
            and hasattr(e.act.target, "faction")
            and e.act.target.faction == subject.faction

            # TODO query syntax:
            # (~Query(e).act.target.faction).unwrap_or() == (~Query(subject).faction).unwrap_or()
        ]

        for e in aggressives:
            move_demeanor_towards(subject, e, -max(1, demeanor_towards(subject, e)))

            # TODO demeanor syntax:
            # subject.demeanor.move(e, -max(1, subject.demeanor.get(e)))

        if attack := self.attacker.try_attacking(subject, perception, self.fight_or_flight.current_target).unwrap_or():
            return attack

        if path_target := (
            self.fight_or_flight.try_producing_target(subject, perception).unwrap_or() or
            self.follower.try_producing_target(subject, perception).unwrap_or()
        ):
            self.pather.going_to = path_target

        if action := self.pather.try_going(subject, perception).unwrap_or():
            return action
