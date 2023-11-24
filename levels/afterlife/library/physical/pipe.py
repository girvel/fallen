from ecs import DynamicEntity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, yellow

# TODO NEXT open pipe BLINKS (bold/not bold or dim/not dim) colors

class Pipe(DynamicEntity):
    name = Name.auto("труба")

    character = ">"
    color = ColorPair(magenta, yellow)
    layer = "physical"
