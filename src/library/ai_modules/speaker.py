from dataclasses import dataclass, field

from ecs import DynamicEntity

from src.library.actions.say import Say
from src.lib.query import Q
from src.systems.ai import Perception


@dataclass
class Speaker:
    messages: list[Say] = field(default_factory=list)

    def use(self, subject: DynamicEntity, perception: Perception) -> Say | None:
        if (
            len(self.messages) > 0
            and any(
                ~Q(e).faction == subject.faction
                for e in perception.vision.physical.values()
            )
        ):
            message, *self.messages = self.messages
            return message
