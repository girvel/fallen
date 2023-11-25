from src.engine.attitude.attitude import Attitude


class Faction:
    Predators = "Predators"
    Church = "Church"
    Disasters = "Disasters"
    Villagers = "Villagers"
    Water = "Water"

class Constants:
    MortalEnemy = -10_000
    Enemy = -1_000
    Neutrality = 0
    Normal = 100
    Friend = 150
    Love = 1_000

def common_attitude():
    return Attitude({Faction.Predators: Constants.Enemy, Faction.Disasters: Constants.MortalEnemy})
