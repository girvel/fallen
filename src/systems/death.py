from src.lib.toolkit import chance


def death_by_chance(subject: 'death_chance', hades: 'entities_to_destroy'):
    if chance(subject.death_chance):
        hades.entities_to_destroy.add(subject)

def sounds_death(subject: 'sound_flag', hades: 'entities_to_destroy'):
    hades.entities_to_destroy.add(subject)


sequence = [death_by_chance, sounds_death]
