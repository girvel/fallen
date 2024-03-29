from dataclasses import dataclass, field

from ecs import Entity

from src.engine.attitude.implementation import Relation
from src.assets.actions.say import Say
from src.assets.ai_modules.language_center import Message
from src.engine.ai import Perception


@dataclass
class Speaker:
    attitude_threshold: int = Relation.Neutrality

    messages: list[Message] = field(default_factory=list)

    def use(self, subject, perception: Perception) -> Say | None:
        if len(self.messages) == 0: return

        next_message = None
        for m in self.messages:
            m.delay -= 1
            if next_message is None and m.delay <= 0: next_message = m

        if (next_message and any(
            subject.attitude.get(e) >= self.attitude_threshold
            for e in perception.vision["physical"].values()
        )):
            self.messages.remove(next_message)
            return next_message.action
