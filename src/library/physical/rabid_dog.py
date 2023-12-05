from src.engine.acting.damage import Weapon, Health, damage_kinds, armor_kinds
from src.engine.ai import Kind, Senses
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

    def __post_init__(self):
        self.name = Name({
            "им": "бешеный пёс",
            "ро": "бешеного пса",
            "да": "бешеному псу",
            "ви": "бешеного пса",
            "тв": "бешеным псом",
            "пр": "бешеном псе",
        })

        self.weapon = Weapon(6, damage_kinds["Piercing"])
        self.health = Health(25, armor_kinds["Organic"])
        self.classifiers = {Kind.Animate}
        self.ai = RabidAi()
        self.senses = Senses(10, 0, 5)

        self.on_death = body_factory
