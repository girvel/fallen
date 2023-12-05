from src.engine.acting.damage import Health, armor_kinds
from src.engine.ai import Kind
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green
from src.library.abstract.material import Material
from src.library.ais.frog_ai import FrogAi


class Frog(Material):
    name = Name("лягушка")
    layer = "physical"
    character = "f"
    color = ColorPair(green)

    def __post_init__(self):
        self.ai = FrogAi()
        self.health = Health(1, armor_kinds["Organic"])
        self.classifiers = {Kind.Animate}
