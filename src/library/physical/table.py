from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import yellow, ColorPair
from src.library.abstract.material import Material


class Table(Material):
    name = Name.auto("стол")
    character = '"'
    color = ColorPair(yellow)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(35, armor_kind.wood)
