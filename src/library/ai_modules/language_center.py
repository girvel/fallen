from dataclasses import dataclass
from functools import singledispatchmethod
from random import randrange

from ecs import DynamicEntity

from src.engine.meme import Idea, Aggression, DangerousEntity
from src.library.actions.say import Say
from src.systems.ai import Perception


@dataclass
class Message:
    action: Say
    delay: int


@dataclass
class LanguageCenter:
    def use(self, subject: DynamicEntity, perception: Perception, ideas: list[Idea]) -> list[Message]:
        speech = []

        for idea in ideas:
            if (message := self.handle(idea.meme, idea, subject, perception)) is not None:
                speech.append(message)

        return speech

    @singledispatchmethod
    def handle(self, meme, idea: Idea, subject: DynamicEntity, perception: Perception):
        pass

    @handle.register
    def _(self, meme: Aggression, idea: Idea, subject: DynamicEntity, perception: Perception):
        if meme.target is subject and subject.attitude.get(meme.source) > 0:
            return Message(Say(
                f"<Не понимает почему {meme.source.name:им} "
                f"нападает на {subject.name:ви}>",
                idea=idea
            ), 0)

        return Message(Say(
            f"<Недовольство агрессивным поведением {meme.source.name:ро}>",
            idea=idea,
        ), randrange(0, 20))

    @handle.register
    def _(self, meme: DangerousEntity, idea: Idea, subject: DynamicEntity, perception: Perception):
        return Message(Say(
            f"<Предостерегает о {meme.entity.name:пр}>"  # TODO in the area X, determined by a closest sign
        ), randrange(0, 100))
