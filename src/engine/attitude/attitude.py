from dataclasses import dataclass, field

from ecs import OwnedEntity

from src.lib.toolkit import random_round


@dataclass
class Attitude:
    relations: dict[OwnedEntity | str, int] = field(default_factory=dict)

    def copy(self):
        return Attitude(
            relations=self.relations.copy(),
        )

    def get(self, target: OwnedEntity) -> int:
        return (
            self.relations.get(target, 0) +
            (self.relations.get(target.faction, 0) if hasattr(target, "faction") else 0)
        )

    def move(self, target: OwnedEntity, shift: int | float, personalization_k: float = .5):
        if target not in self.relations:
            self.relations[target] = 0

        if hasattr(target, "faction"):
            if target.faction not in self.relations:
                self.relations[target.faction] = 0

            personal_offset = random_round(shift * personalization_k)

            self.relations[target] += personal_offset
            self.relations[target.faction] += shift - personal_offset
        else:
            self.relations[target] += shift


