import logging
from dataclasses import dataclass
from functools import singledispatchmethod
from random import randrange

from src.engine.ai import Perception
from src.engine.language.language import placement
from src.engine.meme import Idea, Aggression, DangerousEntity
from src.assets.actions.say import Say


@dataclass
class Message:
    action: Say
    delay: int


@dataclass
class LanguageCenter:
    def use(self, subject, perception: Perception, ideas: list[Idea]) -> list[Message]:
        speech = []

        for idea in ideas:
            if (message := self.handle(idea.meme, idea, subject, perception)) is not None:
                speech.append(message)

        return speech

    @singledispatchmethod
    def handle(self, meme, idea: Idea, subject, perception: Perception):
        pass

    @handle.register
    def _(self, meme: Aggression, idea: Idea, subject, perception: Perception):
        if meme.target is subject and subject.attitude.get(meme.source) > 0:
            return Message(Say(
                f"<Не понимает почему {meme.source.name:им} нападает на {subject.name:ви}>",
                idea=idea
            ), 0)

        return Message(Say(
            f"<Недовольство агрессивным поведением {meme.source.name:ро}>",
            idea=idea,
        ), randrange(0, 250))

    @handle.register
    def _(self, meme: DangerousEntity, idea: Idea, subject, perception: Perception):
        return Message(Say(
            f"<Видел{'а' if subject.sex == 'female' else ''} {meme.entity.name:ви} {placement(subject.level.markup, meme.p)}>",
            idea=idea,
        ), randrange(25, 100))
