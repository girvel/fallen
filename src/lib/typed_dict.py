from typing import TypeVar, Type

R = TypeVar('R')

class TypeDict(dict[type, R]):
    def __init__(self, components):
        super().__init__({type(c): c for c in components})

    def __getitem__(self, item: Type[R]) -> R:
        return super().__getitem__(item)
