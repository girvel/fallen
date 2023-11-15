from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.meme import Idea
from src.library.actions.say import Say
from src.systems.ai import Perception


@dataclass
class LanguageCenter:
    def use(self, subject: DynamicEntity, perception: Perception, ideas: list[Idea]) -> list[Say]:
        speech = []

        for idea in ideas:  # TODO NEXT aggression vs. subject
            match idea.meme:
                case Aggression as aggression:  # TODO maybe split these to functions?
                    speech.append(Say(
                        f"<Недовольство агрессивным поведением {aggression.source.name:тв}>",
                        idea=idea,
                    ))

        return speech
