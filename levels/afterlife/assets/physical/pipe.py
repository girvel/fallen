from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, yellow, cyan, red, green, blue
from src.assets.abstract.material import Material


class Pipe(Material):
    name = Name.auto("труба")

    character = ">"
    color = ColorPair(red, yellow)
    layer = "physical"

    def __post_init__(self, is_open=False):
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
