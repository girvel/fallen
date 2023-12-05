from src.engine.acting.damage import Health, armor_kinds
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green
from src.library.abstract.material import Material


class Bush(Material):
    name = Name("куст")
    character = 'b'
    color = ColorPair(green)
    solid_flag = None
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(20, armor_kinds["Organic"])
