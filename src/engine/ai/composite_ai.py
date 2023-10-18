from dataclasses import dataclass
from typing import Any, TypeVar, Type

R = TypeVar('R')

@dataclass
class CompositeAi:
    components: dict[type, Any]

    def __init__(self, components):
        self.components = {type(c): c for c in components}

    def __getitem__(self, item: Type[R]) -> R:
        return self.components[item]
