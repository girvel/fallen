import random

from src.assets.abstract.material import Material
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan, red, magenta, yellow, blue
from src.lib.limited import Limited


class Flower(Material):
    name = Name.auto("цветок")
    character = 'F'
    layer = "tiles"

    def __post_init__(self):
        self.sex = random.choice(["male", "female", "mercury"])
        self.health = Limited(2)

        if not hasattr(self, "color"):  # for subclassing
            self.color = ColorPair(random.choice([cyan, red, magenta, blue, yellow]))
