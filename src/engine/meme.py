from ecs import DynamicEntity
from rust_enum import enum, Case


@enum
class Meme:
    Nothing = Case()
    Danger = Case(faction=str, position=str)
    MoraleChange = Case(entity=DynamicEntity, offset=int)
