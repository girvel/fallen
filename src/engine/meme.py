from dataclasses import dataclass
from typing import TypeAlias

from ecs import DynamicEntity

from src.lib.vector import int2


@dataclass
class Aggression:
    source: DynamicEntity
    target: DynamicEntity

@dataclass
class DangerousEntity:
    p: int2
    entity: DynamicEntity

Meme: TypeAlias = Aggression | DangerousEntity


@dataclass
class Idea:
    meme: Meme
    weight: float
    source: DynamicEntity = None
