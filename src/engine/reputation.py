from src.lib.toolkit import random_round


def demeanor_towards(subject, target):
    return (
        subject.personal_relations.get(target, 0) +
        (subject.faction_relations.get(target.faction, 0) if "faction" in target else 0)
    )

def move_demeanor_towards(subject, target, shift, personalization_k=0.5):
    if target not in subject.personal_relations:
        subject.personal_relations[target] = 0

    if hasattr(target, "faction"):
        if target.faction not in subject.faction_relations:
            subject.faction_relations[target.faction] = 0

        personal_offset = random_round(shift * personalization_k)

        subject.personal_relations[target] += personal_offset
        subject.faction_relations[target.faction] += shift - personal_offset
    else:
        subject.personal_relations[target] += shift


class Faction:
    Predators = "Predators"
    Church = "Church"
