from ecs import DynamicEntity

from src.engine.acting.actions.say import Say
from src.engine.ai.attacker import Attacker
from src.engine.ai.fight_or_flight import FightOrFlight
from src.engine.ai.follower import Follower
from src.engine.ai.morale import Morale
from src.engine.ai.pather import Pather
from src.engine.ai.spacial_memory import SpacialMemory
from src.systems.ai import Perception


class KnightAi(DynamicEntity):
    def __init__(self):
        self.spacial_memory = SpacialMemory()
        self.pather = Pather()
        self.follower = Follower(3)
        self.fight_or_flight = FightOrFlight(True)
        self.attacker = Attacker()
        self.morale = Morale()

    def make_decision(self, subject, perception: Perception):
        self.spacial_memory.use(subject, perception)
        self.morale.use(subject, perception)

        if attack := self.attacker.try_attacking(subject, perception, self.fight_or_flight.current_target):
            return attack

        if (
            (path_target := self.fight_or_flight.use(subject, perception)) != FightOrFlight.no_change_signal or
            (path_target := self.follower.use(subject, perception)) != Follower.no_change_signal
        ):
            self.pather.going_to = path_target

        if action := self.pather.use(subject, perception, self.spacial_memory):
            return action
