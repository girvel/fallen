from src.components import DyingWithChance, Destructor, Sound
from src.lib.toolkit import chance


sequence = []

@sequence.append
def death_by_chance(subject: DyingWithChance, hades: Destructor):
    if chance(subject.death_chance):
        hades.entities_to_destroy.add(subject)

@sequence.append
def sounds_death(subject: Sound, hades: Destructor):
    hades.entities_to_destroy.add(subject)
