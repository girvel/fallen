from ecs import DynamicEntity

from src.engine.acting.actions.splash_attack import SplashAttack
from src.engine.acting.damage import Weapon, DamageKind
from src.engine.attitude.implementation import Faction
from src.engine.name import Name
from src.engine.output.colors import ColorPair, red
from src.entities.ais.static_ai import StaticAi
from src.lib.toolkit import death_chance_from_half_life


class Fire(DynamicEntity):
    name = Name("Огонь")
    character = '*'
    color = ColorPair(red)

    layer = "effects"

    def __init__(self, half_life=float('inf'), heat=5, **attributes):
        self.weapon = Weapon(heat, DamageKind.Fire)
        self.ai = StaticAi(lambda subject, _: SplashAttack(subject.p, 0))
        self.death_chance = death_chance_from_half_life(half_life)
        self.faction = None if half_life == float('inf') else Faction.Disaster

        super().__init__(**attributes)
