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
        # Morale
        aggressives = [
            m.author
            for l in perception.vision.information.values()
            for m in l
            if isinstance(m.value, Attack)
            and m.value.target is not None
            and "faction" in m.value.target
            and m.value.target.faction == subject.faction
        ]

        for e in aggressives:
            logging.debug(e)
            move_demeanor_towards(subject, e, -min(1, demeanor_towards(subject, e)))

        if attack := self.attacker.try_attacking(subject, perception, self.fight_or_flight.current_target).unwrap_or():
            return attack

        if path_target := (
            self.fight_or_flight.try_producing_target(subject, perception).unwrap_or() or
            self.follower.try_producing_target(subject, perception).unwrap_or()
        ):
            self.pather.going_to = path_target

        if action := self.pather.try_going(subject, perception).unwrap_or():
            return action
