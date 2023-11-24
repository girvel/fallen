from ecs import DynamicEntity

from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, yellow, cyan, red, green, blue


# TODO NEXT open pipe BLINKS (bold/not bold or dim/not dim) colors

class Pipe(DynamicEntity):
    name = Name.auto("труба")

    character = ">"
    color = ColorPair(magenta, yellow)
    layer = "physical"

    def __init__(self, is_open=False):
        if is_open:
            self.blink_colors = [
                ColorPair(red, yellow),
                ColorPair(cyan, yellow),
                ColorPair(magenta, yellow),
                ColorPair(green, yellow),
                ColorPair(blue, yellow),
                ColorPair(yellow, yellow),
            ]

            self.blink_colors_i = 0
            self.is_blinking = False
