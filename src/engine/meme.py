from dataclasses import dataclass
from typing import TypeAlias

from ecs import DynamicEntity


@dataclass
class Aggression:
    source: DynamicEntity
    target: DynamicEntity

Meme: TypeAlias = Aggression


@dataclass
class Idea:
    meme: Meme
    weight: float
    source: DynamicEntity = None
