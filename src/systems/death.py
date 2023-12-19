from src.components import DyingWithChance, Sound, Hades
from src.lib.toolkit import chance


sequence = []

@sequence.append
def death_by_chance(subject: DyingWithChance, hades: Hades):
    if chance(subject.death_chance):
        hades.push(subject)

@sequence.append
def sounds_death(subject: Sound, hades: Hades):
    hades.push(subject)
