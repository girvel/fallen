from src.assets.tiles.body import generate_body_factory, body_factory
from src.engine.acting import armor_kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green
from src.assets.abstract.material import Material
from src.assets.ais.frog_ai import FrogAi
from src.lib.limited import Limited


class Frog(Material):
    name = Name.auto("лягушка")
    layer = "physical"
    character = "f"
    color = ColorPair(green)

    animate_flag = None

    def __post_init__(self):
        self.ai = FrogAi()
        self.health = Limited(2)

        self.on_destruction = generate_body_factory(self)

    on_destruction = body_factory
