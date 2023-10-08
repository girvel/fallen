from src.engine.attitude.attitude import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"
    Disaster = "Disaster"
    Villagers = "Villagers"
    Water = "Water"

def common_attitude():
    return Attitude({Faction.Predators: -100, Faction.Disaster: -10_000})
