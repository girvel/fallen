from ecs import Entity

from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow
from src.library.abstract.material import Material


class AbstractWall(Material):
    name = Name.auto("стенка")
    character = None
    color = ColorPair(yellow)
    layer = "physical"

    boring_flag = None

    def __post_init__(self):
        self.health = Health(2000, armor_kind.wood)
