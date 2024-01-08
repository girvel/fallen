from src.assets.abstract.material import Material
from src.engine.language.language import placement, Near, In
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, yellow


class Sign(Material):
    name = Name.auto("знак")
    character = "S"
    color = ColorPair(yellow)
    layer = "physical"

    def after_creation(self):
        match placement(self.level.markup, self.p):
            case Near(place) | In(place):
                self.name = place.name
