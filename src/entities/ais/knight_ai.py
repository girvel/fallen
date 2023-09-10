from ecs import OwnedEntity
from rust_enum import Option

from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather


class KnightAi(OwnedEntity):
    def __init__(self):
        self.pather = Pather()
        self.follower = Follower(3)

    def make_decision(self, subject, perception):
        match self.follower.try_producing_target(subject, perception):
            case Option.Some(p): self.pather.going_to = p

        if (action := self.pather.try_going(subject, perception)) is not None: return action
