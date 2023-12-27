from src.engine.acting.damage import Health
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green
from src.library.abstract.material import Material
from src.library.ais.frog_ai import FrogAi


class Frog(Material):
    name = Name.auto("лягушка")
    layer = "physical"
    character = "f"
    color = ColorPair(green)

    animate_flag = None

    def __post_init__(self):
        self.ai = FrogAi()
        self.health = Health(1, armor_kind.none)
