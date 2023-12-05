from src.engine.acting.damage import armor_kinds, Health
from src.engine.language.name import Name
from src.library.abstract.material import Material


class Window(Material):
    name = Name("окно")
    character = '='
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(10, armor_kinds["Glass"])
