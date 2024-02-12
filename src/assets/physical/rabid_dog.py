from src.assets.abstract.material import Material
from src.assets.ais.rabid_ai import RabidAi
from src.assets.items.dog_teeth import DogTeeth
from src.assets.tiles.body import generate_body_factory
from src.engine.ai import Senses
from src.engine.attitude.implementation import Faction
from src.engine.inventory import Inventory
from src.engine.language.name import Name
from src.engine.output.colors import magenta, ColorPair
from src.lib.limited import Limited


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

        self.inventory = Inventory(weapon=DogTeeth())
        self.health = Limited(26)
        self.ai = RabidAi()
        self.senses = Senses(10, 0, 5)

        self.on_destruction = generate_body_factory(self)
