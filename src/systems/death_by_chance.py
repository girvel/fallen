import logging

from ecs import create_system

from src.lib.toolkit import chance


@create_system
def death_by_chance(subject: 'death_chance', hades: 'entities_to_destroy'):
    logging.debug(subject)
    if chance(subject.death_chance):
        hades.entities_to_destroy.append(subject)
