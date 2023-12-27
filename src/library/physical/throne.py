from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.material import Material


class Throne(Material):
    name = Name.auto("трон")
    layer = "physical"
    character = 't'
    color = ColorPair(yellow)

    def __post_init__(self):
        self.health = Health(700, armor_kind.wood)
