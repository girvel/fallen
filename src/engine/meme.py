from dataclasses import dataclass

from ecs import DynamicEntity


@dataclass
class MoraleChange:
    entity: DynamicEntity
    offset: int

Meme = MoraleChange
