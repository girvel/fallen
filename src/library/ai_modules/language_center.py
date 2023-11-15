from dataclasses import dataclass
from functools import singledispatch, singledispatchmethod

from ecs import DynamicEntity

from src.engine.meme import Idea, Aggression
from src.library.actions.say import Say
from src.systems.ai import Perception


@dataclass
class LanguageCenter:
    def use(self, subject: DynamicEntity, perception: Perception, ideas: list[Idea]) -> list[Say]:
        speech = []

        for idea in ideas:  # TODO NEXT aggression vs. subject
            if (message := self.handle(idea.meme, idea)) is not None:
                speech.append(message)

        return speech

    @singledispatchmethod
    def handle(self, meme, idea: Idea):
        pass

    @handle.register
    def _(self, meme: Aggression, idea: Idea):
        return Say(
            f"<Недовольство агрессивным поведением {meme.source.name:ро}>",
            idea=idea,
        )
