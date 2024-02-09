from src.engine.ai import Senses
from src.engine.inventory import Inventory
from src.lib.toolkit import assert_attributes
from src.assets.abstract.material import Material
from src.assets.tiles.body import generate_body_factory

required_attributes = "character, sex, name, health".split(", ")

class Humanoid(Material):
    layer = "physical"

    ai = None
    act = None

    human_flag = None
    animate_flag = None

    def __init__(self, **kwargs):
        self.senses = Senses(12, 0, 0)
        self.inventory = Inventory()
        self.on_destruction = generate_body_factory(self)

        super().__init__(**kwargs)

        assert_attributes(self, required_attributes)
