import random

from src.assets.abstract.material import Material
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green, yellow
from src.lib.limited import Limited


class Tree(Material):
    name = Name.auto("дерево")
    character = 'T'
    color = ColorPair(yellow, green)
    solid_flag = None
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Limited(random.randrange(250, 2000) + 1)
