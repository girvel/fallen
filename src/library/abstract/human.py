from src.engine.acting.damage import Weapon
from src.engine.ai import Kind, Senses
from src.library.abstract.material import Material
from src.library.ais.dummy_ai import DummyAi
from src.library.tiles.body import body_factory

required_attributes = "character, sex, name, health".split(", ")

class Human(Material):
    layer = "physical"

    human_flag = None

    def __init__(self, **kwargs):
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        self.classifiers = {Kind.Animate}

        self.skill = {}
        self.weapon = Weapon(1, "Crushing")

        self.on_death = body_factory

        super().__init__(**kwargs)

        if len(missing_attributes := [a for a in required_attributes if not hasattr(self, a)]) > 0:
            raise NotImplementedError(f"Human subclass {type(self)} is missing attributes {missing_attributes}")
