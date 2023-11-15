from dataclasses import dataclass

from ecs import DynamicEntity

from src.engine.acting.action import Action
from src.engine.acting.damage import attack
from src.library.special.genesis import Genesis
from src.library.special.hades import Hades


@dataclass
class Attack(Action):
    target: DynamicEntity  # never None, always exists

    def execute(self, actor: DynamicEntity, hades: Hades, genesis: Genesis):
        attack(actor, self.target, hades)
