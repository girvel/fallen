from src.engine.acting.damage import armor_kinds, Health
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.material import Material


class Throne(Material):
    name = Name("трон")
    layer = "physical"
    character = 't'
    color = ColorPair(yellow)

    def __post_init__(self):
        self.health = Health(700, armor_kinds["Wood"])
