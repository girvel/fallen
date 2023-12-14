from dataclasses import dataclass
from typing import TypeVar, Generic, Any, Optional, Type

T = TypeVar('T')
R = TypeVar("R")

@dataclass(frozen=True)
class Q(Generic[T]):
    """Allows to remove long walls of hasattrs from the code.

    `~Q(e).a.b` returns None if any of the `e`, `e.a`, `e.a.b` is None or else returns the value of `e.a.b`.
    """

    __object: Optional[T]

    def __invert__(self) -> T:
        return self.__object

    def __getattr__(self, item: str) -> "Q[Any]":
        return Q(getattr(self.__object, item, None))

    # TODO __getitem__ <-> Q_isinstance
    def __getitem__(self, cast_type: Type[R]) -> "Q[R]":
        return Q(self.__object if isinstance(self.__object, cast_type) else None)

    def __call__(self, *args, **kwargs):
        return Q(self.__object(*args, **kwargs) if callable(self.__object) else None)

    def Q_len(self) -> "Q[int]":
        return Q(len(self.__object) if self.__object is not None else None)
