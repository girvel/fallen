from src.engine.acting.damage import Weapon
from src.engine.ai import Senses
from src.lib.toolkit import assert_attributes
from src.library.abstract.material import Material
from src.library.tiles.body import generate_body_factory

required_attributes = "character, sex, name, health".split(", ")

class Humanoid(Material):
    layer = "physical"

    ai = None
    act = None

    human_flag = None
    animate_flag = None

    def __init__(self, **kwargs):
        self.senses = Senses(12, 0, 0)

        self.skill = {}
        self.weapon = Weapon(1, "Crushing")

        super().__init__(**kwargs)

        assert_attributes(self, required_attributes)

    def on_destruction(self, *args):
        return generate_body_factory(self)(*args)
