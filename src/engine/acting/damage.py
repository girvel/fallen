import logging

from src.components import Hades
from src.engine.parenting import iter_parenting_stack
from src.lib.query import Q
from src.lib.toolkit import random_round



def try_inflict_damage(source, target, power: float, hades: Hades) -> bool:
    if not hasattr(target, "health"): return False
    inflict_damage(source, target, power, hades)
    return True


def inflict_damage(source, target, power: float, hades: Hades):
    power = random_round(power)

    if not hasattr(target, "boring_flag"):
        logging.info(f"{power} damage from {source.name} to {target.name}")

    target.health.move(-power)
    target.last_damaged_by = (~Q(target).last_damaged_by or []) + [source]
    # TODO this practice is ugly
    #      maybe do Statistics global object with all this crap?

    if target.health.current <= 0:
        if not hasattr(target, "boring_flag"):
            logging.info(f"{target.name} is killed")

        hades.push(target)

        for killer in iter_parenting_stack(source):
            if not hasattr(killer, "last_killed"):  # TODO this practice is ugly
                killer.last_killed = []

            killer.last_killed.append(target)
