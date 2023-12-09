import numpy
import tcod.map

from src.components import GridContainer, Sentient, RailsComponent
from src.engine.ai import Perception, GridProxy, borders_from_radius, create_square_rhombus


sequence = []


@sequence.append
def update_transparency_cache(level: GridContainer):
    for y, line in enumerate(level.grids["physical"][0]):
        for x, e in enumerate(line):
            level.transparency_cache[x, y] = int(e is None or not hasattr(e, "solid_flag"))


@sequence.append
def run_rails(rails: RailsComponent):
    rails.level.rails_effect = rails.get_effect()


@sequence.append
def think(subject: Sentient):
    is_railed = subject in subject.level.rails_effect

    if is_railed:
        subject.act = subject.level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if not hasattr(subject, "god_vision_flag"):
        fov = tcod.map.compute_fov(subject.level.transparency_cache, subject.p, subject.senses.vision)
    else:
        fov = None

    act = subject.ai.make_decision(subject, Perception(
        {
            layer: GridProxy(grid, subject.p, subject.senses.vision, mask=fov)
            for layer, grid in subject.level.grids.items()
        },
        GridProxy(subject.level.grids["sounds"], subject.p, subject.senses.hearing),
        GridProxy(subject.level.grids["physical"], subject.p, subject.senses.smell),
    ))

    if not is_railed:
        subject.act = act

