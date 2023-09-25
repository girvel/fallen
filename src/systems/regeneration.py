from ecs import create_system

from src.lib.toolkit import random_round

sequence = []

@sequence.append
@create_system
def regenerate(subject: "health"):
    subject.health.amount.move(random_round(.007))
