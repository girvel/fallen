from dataclasses import dataclass, field
from typing import TypeVar, Generic, Any

T = TypeVar('T')

# TODO ~Query(subject).act[Inspect].subject
@dataclass
class Query(Generic[T]):
    """Allows to remove long walls of hasattrs from the code.

    `~Query(e).a.b` returns None if any of the `e`, `e.a`, `e.a.b` is None or else returns the value of `e.a.b`.
    """

    object: T
    path: list[str] = field(default_factory=list)

    def __getattr__(self, item: str) -> "Query":
        return Query(self.object, self.path + [item])

    def __invert__(self) -> Any:
        result = self.object

        for attribute in self.path:
            if result is None:
                return

            result = getattr(result, attribute, None)

        return result