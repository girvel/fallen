from src.lib.toolkit import random_round


def demeanor_towards(subject, target):
    return (
        subject.personal_relations[target] + (subject.faction_relations[target.faction] if "faction" in target else 0)
    )

def move_demeanor_towards(subject, target, shift):
    if "faction" in target:
        personal_offset = random_round(shift / 2)

        subject.personal_relations[target] += personal_offset
        subject.faction_relations[target.faction] += shift - personal_offset
    else:
        subject.personal_relations[target] += shift


class Faction:
    Predators = "Predators"
    Church = "Church"
