from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class Inventory:
    _items: list[Any] = field(default_factory=list)
    _hand: Optional[Any] = None

    def get_hand(self):
        return self._hand

    def get_items(self):
        return self._items.copy()
