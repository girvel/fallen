from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, magenta, black
from src.assets.tiles.flower import Flower


class ExoticFlower(Flower):
    name = Name({
        "им": "экзотический цветок",
        "ро": "экзотического цветка",
        "да": "экзотическому цветку",
        "ви": "экзотический цветок",
        "тв": "экзотическим цветком",
        "пр": "экзотическом цветке",
    })

    color = ColorPair(black, magenta)
