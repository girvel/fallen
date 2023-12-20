import logging

import tcod.map

from src.components import GridContainer, Sentient, RailsComponent
from src.engine.ai import Perception, MaskedGridProxy, Senses, GridProxy

sequence = []


@sequence.append
def run_rails(rails: RailsComponent):
    rails.level.rails_effect = rails.get_effect()


@sequence.append
def think(subject: Sentient):
    is_railed = subject in subject.level.rails_effect

    if is_railed:
        subject.act = subject.level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if subject.ai is None: return

    senses = subject.senses if hasattr(subject, "senses") else Senses(0, 0, 0)

    if not hasattr(subject, "god_vision_flag"):
        fov = tcod.map.compute_fov(subject.level.transparency_cache, subject.p, senses.vision)
    else:
        fov = None

    act = subject.ai.make_decision(subject, Perception(
        {
            layer: MaskedGridProxy(grid, subject.p, senses.vision, fov)
            for layer, grid in subject.level.grids.items()
        },
        GridProxy(subject.level.grids["sounds"], subject.p, senses.hearing),
        GridProxy(subject.level.grids["physical"], subject.p, senses.smell),
    ))

    if not is_railed:
        subject.act = act

