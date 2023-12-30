from src.engine.acting.damage import DamageSource
from src.engine.acting import damage_kind
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, red
from src.lib.toolkit import death_chance_from_half_life
from src.assets.abstract.material import Material
from src.assets.actions.splash_attack import SplashAttack
from src.assets.ais.static_ai import StaticAi


class Fire(Material):
    name = Name.auto("огонь")
    character = '*'
    color = ColorPair(red)

    layer = "effects"

    boring_flag = None

    def __post_init__(self, half_life=float('inf'), heat=5, parent=None):
        self.damage_source = DamageSource(heat, damage_kind.fire)
        self.ai = StaticAi(lambda subject, _: SplashAttack(subject.p, 0))
        self.death_chance = death_chance_from_half_life(half_life)
        self.faction = None if half_life == float('inf') else Faction.Disasters
        self.parent = parent
