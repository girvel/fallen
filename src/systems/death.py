import logging

from ecs import create_system

from src.lib.toolkit import chance


@create_system
def death_by_chance(subject: 'death_chance', hades: 'entities_to_destroy'):
    if chance(subject.death_chance):
        hades.entities_to_destroy.add(subject)

@create_system
def sounds_death(subject: 'sound_flag', hades: 'entities_to_destroy'):
    hades.entities_to_destroy.add(subject)


sequence = [death_by_chance, sounds_death]
