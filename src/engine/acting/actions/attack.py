from dataclasses import dataclass

from ecs import OwnedEntity

from src.engine.acting.action import Action
from src.engine.acting.damage import inflict_damage
from src.entities.special.level import Level


@dataclass
class Attack(Action):
    target: OwnedEntity  # never None, always exists

    def execute(self, actor: OwnedEntity, level: Level, hades: OwnedEntity, genesis: OwnedEntity):
        inflict_damage(self.target, actor.weapon, hades)
