from dataclasses import dataclass

from ecs import OwnedEntity

from src.engine.acting.action import Action
from src.engine.acting.damage import inflict_damage
from src.entities.meme import Meme
from src.entities.special.genesis import Genesis
from src.entities.special.hades import Hades
from src.entities.special.infosphere import Infosphere
from src.entities.special.level import Level


@dataclass
class Attack(Action):
    target: OwnedEntity  # never None, always exists

    def execute(self, actor: OwnedEntity, level: Level, infosphere: Infosphere, hades: Hades, genesis: Genesis):
        inflict_damage(self.target, actor.weapon, hades)

        m = Meme(actor, self)
        genesis.entities_to_create.append(m)
        infosphere.information_grid[self.target.p] += [m]
