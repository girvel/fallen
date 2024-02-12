from dataclasses import dataclass

from ecs import Entity

from src.components import Genesis, Hades
from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import try_inflict_damage


# TODO implement skill
@dataclass
class WeaponAttack(Aggressive, Action):
    target: Entity

    def execute(self, actor, hades: Hades, genesis: Genesis):
        try_inflict_damage(actor, self.target, actor.inventory.get_current_damage(), hades)

    def get_victims(self, actor) -> list[Entity]:
        return [self.target]
