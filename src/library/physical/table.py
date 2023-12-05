from src.engine.acting.damage import armor_kinds, Health
from src.engine.ai import Kind
from src.engine.language.name import Name
from src.engine.output.colors import yellow, ColorPair
from src.library.abstract.material import Material


class Table(Material):
    name = Name("стол")
    character = '"'
    color = ColorPair(yellow)
    classifiers = {Kind.Table}
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(35, armor_kinds["Wood"])
