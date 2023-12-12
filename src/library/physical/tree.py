import random

from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green, yellow
from src.library.abstract.material import Material


class Tree(Material):
    name = Name("дерево")
    character = 'T'
    color = ColorPair(yellow, green)
    solid_flag = None
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(random.randrange(250, 2000), armor_kind.wood)
