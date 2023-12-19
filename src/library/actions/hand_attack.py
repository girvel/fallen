from dataclasses import dataclass

from ecs import Entity

from src.engine.acting.action import Action
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import attack
from src.components import Genesis, Hades


@dataclass
class HandAttack(Action, Aggressive):
    target: Entity  # never None, always exists

    def execute(self, actor, hades: Hades, genesis: Genesis):
        attack(actor, self.target, hades)

    def get_victims(self, actor) -> list[Entity]:
        return [self.target]
