from src.engine.attitude.abstract import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"

def common_attitude():
    return Attitude(factional={Faction.Predators: -100})
