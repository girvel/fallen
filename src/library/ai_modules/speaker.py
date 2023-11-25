from dataclasses import dataclass, field

from ecs import DynamicEntity

from src.engine.attitude.implementation import Constants
from src.library.actions.say import Say
from src.library.ai_modules.language_center import Message
from src.systems.ai import Perception


@dataclass
class Speaker:
    attitude_threshold: int = Constants.Normal

    messages: list[Message] = field(default_factory=list)

    def use(self, subject: DynamicEntity, perception: Perception) -> Say | None:
        if len(self.messages) == 0: return

        next_message = None
        for m in self.messages:
            m.delay -= 1
            if next_message is None and m.delay <= 0: next_message = m

        if (next_message and any(
            subject.attitude.get(e) >= self.attitude_threshold
            for e in perception.vision.physical.values()
        )):
            self.messages.remove(next_message)
            return next_message.action
