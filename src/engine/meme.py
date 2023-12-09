from dataclasses import dataclass
from typing import TypeAlias

from ecs import Entity

from src.lib.vector.vector import int2


@dataclass
class Aggression:
    source: Entity
    target: Entity

@dataclass
class DangerousEntity:
    p: int2
    entity: Entity

@dataclass
class Murder:
    source: Entity
    target: Entity

Meme: TypeAlias = Aggression | DangerousEntity | Murder


@dataclass
class Idea:
    meme: Meme
    weight: float
    source: Entity = None
