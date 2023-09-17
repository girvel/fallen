from src.engine.attitude.attitude import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"
    Disaster = "Disaster"

def common_attitude():
    return Attitude({Faction.Predators: -100, Faction.Disaster: -10_000})
