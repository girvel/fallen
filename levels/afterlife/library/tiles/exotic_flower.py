from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, black
from src.library.tiles.flower import Flower


class ExoticFlower(Flower):
    name = Name({  # TODO NEXT Name.auto
        "им": "экзотический цветок",
        "ро": "экзотического цветка",
        "да": "экзотическому цветку",
        "ви": "экзотический цветок",
        "тв": "экзотическим цветком",
        "пр": "экзотическом цветке",
    })

    color = ColorPair(black, magenta)
