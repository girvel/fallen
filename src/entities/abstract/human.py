from ecs import DynamicEntity

from src.entities.tiles.body import body_factory
from src.systems.ai import Kind

required_attributes = "character, sex, name, health".split(", ")

class Human(DynamicEntity):
    on_death = body_factory
    layer = "physical"

    def __init__(self, *args, **kwargs):
        self.classifiers = {Kind.Animate}

        self.__post_init__(*args, **kwargs)
        if len(missing_attributes := [a for a in required_attributes if not hasattr(self, a)]) > 0:
            raise NotImplementedError(f"Human subclass {type(self)} is missing attributes {missing_attributes}")

    def __post_init__(self, *args, **kwargs):
        pass
