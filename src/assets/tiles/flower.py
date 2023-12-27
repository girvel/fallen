import random

from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, cyan, red, magenta, yellow, blue, white
from src.assets.abstract.material import Material


class Flower(Material):
    name = Name.auto("цветок")
    character = 'F'
    layer = "tiles"

    def __post_init__(self):
        self.sex = random.choice(["male", "female", "mercury"])
        self.health = Health(1, armor_kind.none)

        if not hasattr(self, "color"):  # for subclassing
            self.color = ColorPair(random.choice([cyan, red, magenta, blue, yellow]))
