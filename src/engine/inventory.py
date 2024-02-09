from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class Inventory:
    items: list[Any] = field(default_factory=list)
    hand: Optional[Any] = None
