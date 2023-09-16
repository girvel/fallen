from dataclasses import dataclass, field

from ecs import OwnedEntity

from src.lib.toolkit import random_round


@dataclass
class Attitude:
    factional: dict[OwnedEntity, int] = field(default_factory=dict)
    personal: dict[OwnedEntity, int] = field(default_factory=dict)

    def copy(self):
        return Attitude(
            factional=self.factional.copy(),
            personal=self.personal.copy(),
        )

    def get(self, target: OwnedEntity) -> int:
        return (
            self.personal.get(target, 0) +
            (self.factional.get(target.faction, 0) if hasattr(target, "faction") else 0)
        )

    def move(self, target: OwnedEntity, shift: int | float, personalization_k: float = .5):
        if target not in self.personal:
            self.personal[target] = 0

        if hasattr(target, "faction"):
            if target.faction not in self.factional:
                self.factional[target.faction] = 0

            personal_offset = random_round(shift * personalization_k)

            self.personal[target] += personal_offset
            self.factional[target.faction] += shift - personal_offset
        else:
            self.personal[target] += shift


