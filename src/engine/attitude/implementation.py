from src.engine.attitude.attitude import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"
    Disasters = "Disasters"
    Villagers = "Villagers"
    Water = "Water"

def common_attitude():
    return Attitude({Faction.Predators: -1_000, Faction.Disasters: -10_000})
