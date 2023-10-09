from ecs import DynamicEntity

from src.engine.acting.damage import Health, ArmorKind
from src.engine.name import Name
from src.engine.output.colors import ColorPair, green
from src.entities.ais.frog_ai import FrogAi
from src.systems.ai import Kind


class Frog(DynamicEntity):
    name = Name("Frog")
    layer = "physical"
    character = "f"
    color = ColorPair(green)

    def __init__(self):
        self.ai = FrogAi()
        self.health = Health(1, ArmorKind.Organic)
        self.classifiers = {Kind.Animate}
