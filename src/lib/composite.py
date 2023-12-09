from typing import TypeVar, Type, Any, Iterable

R = TypeVar('R')

class Composite(dict[type, Any]):
    def __init__(self, components: Iterable[Any]):
        super().__init__({type(c): c for c in components})

    def __getitem__(self, item: Type[R]) -> R:
        return super().__getitem__(item)
