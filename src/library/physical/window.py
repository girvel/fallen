from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.library.abstract.material import Material


class Window(Material):
    name = Name.auto("окно")
    character = '='
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(10, armor_kind.glass)
