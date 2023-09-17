from src.engine.attitude.attitude import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"

def common_attitude():
    return Attitude({Faction.Predators: -100})
