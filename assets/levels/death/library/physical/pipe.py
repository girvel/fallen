from ecs import DynamicEntity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, yellow


class Pipe(DynamicEntity):  # TODO open pipe BLINKS (bold/not bold or dim/not dim) colors
    name = Name.auto("труба")

    character = ">"
    color = ColorPair(magenta, yellow)
    layer = "physical"
