from ecs import DynamicEntity

from src.engine.acting.damage import Weapon
from src.library.ais.dummy_ai import DummyAi
from src.library.tiles.body import body_factory
from src.systems.ai import Kind, Senses

required_attributes = "character, sex, name, health".split(", ")

class Human(DynamicEntity):
    layer = "physical"

    human_flag = None

    def __init__(self, *args, **kwargs):
        self.senses = Senses(12, 0, 0)
        self.ai = DummyAi()

        self.classifiers = {Kind.Animate}

        self.skill = {}
        self.weapon = Weapon(1, "Crushing")

        self.on_death = body_factory

        self.__post_init__(*args, **kwargs)

        if len(missing_attributes := [a for a in required_attributes if not hasattr(self, a)]) > 0:
            raise NotImplementedError(f"Human subclass {type(self)} is missing attributes {missing_attributes}")

    def __post_init__(self, *args, **kwargs):
        pass
