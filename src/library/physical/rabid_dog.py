from src.engine.acting.damage import Weapon, Health
from src.engine.acting import armor_kind
from src.engine.acting import damage_kind
from src.engine.ai import Senses
from src.engine.attitude.implementation import Faction
from src.engine.language.name import Name
from src.engine.output.colors import magenta, ColorPair
from src.library.abstract.material import Material
from src.library.ais.rabid_ai import RabidAi
from src.library.tiles.body import body_factory


class RabidDog(Material):
    character = 'd'
    color = ColorPair(magenta)
    layer = "physical"

    faction = Faction.Predators

    animate_flag = None

    def __post_init__(self):
        self.name = Name({
            "им": "бешеный пёс",
            "ро": "бешеного пса",
            "да": "бешеному псу",
            "ви": "бешеного пса",
            "тв": "бешеным псом",
            "пр": "бешеном псе",
        })

        self.weapon = Weapon(6, damage_kind.piercing)
        self.health = Health(25, armor_kind.none)
        self.ai = RabidAi()
        self.senses = Senses(10, 0, 5)

        self.on_death = body_factory
