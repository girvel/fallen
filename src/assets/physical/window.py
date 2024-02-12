from src.assets.abstract.material import Material
from src.engine.language.name import Name
from src.lib.limited import Limited


class Window(Material):
    name = Name.auto("окно")
    character = '='
    layer = "physical"

    boring_flag = None
    hard_flag = None

    def __post_init__(self):
        self.health = Limited(10 + 1)
