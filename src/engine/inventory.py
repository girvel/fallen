from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class Inventory:
    items: list[Any] = field(default_factory=list)
    weapon: Optional[Any] = None
    is_weapon_out: bool = False
    
    def get_current_damage(self) -> float:
        return getattr(self.weapon, "damage", 1)
