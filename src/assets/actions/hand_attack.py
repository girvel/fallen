from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.components import Genesis, Hades
from src.engine.acting.damage import inflict_damage, try_inflict_damage


# TODO implement skill
@dataclass
class HandAttack(Aggressive, Action):
    target: Entity

    def execute(self, actor, hades: Hades, genesis: Genesis):
        try_inflict_damage(self.target, actor, getattr(actor.inventory.hand, "damage", 1), hades)

    def get_victims(self, actor) -> list[Entity]:
        return [self.target]
