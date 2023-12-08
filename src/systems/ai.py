import numpy
import tcod.map

from src.components import GridContainer, Sentient, RailsComponent
from src.engine.ai import Perception, GridProxy, borders_from_radius


# TODO NEXT move this
def create_square_rhombus(position, radius, field_size):
    return numpy.fromfunction(
        lambda x, y: abs(x - position[0]) + abs(y - position[1]) <= radius,
        field_size
    )


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
        fov = numpy.full(subject.level.transparency_cache.shape, True)

    act = subject.ai.make_decision(subject, Perception(
        {
            layer: GridProxy(
                grid, fov,
                *borders_from_radius(subject.p, subject.senses.vision, subject.level.size)
            )
            for layer, grid in subject.level.grids.items()
        },
        GridProxy(
            subject.level.grids["sounds"],
            create_square_rhombus(subject.p, subject.senses.hearing, subject.level.size),
            *borders_from_radius(subject.p, subject.senses.hearing, subject.level.size),
        ),
        GridProxy(
            subject.level.grids["physical"],
            create_square_rhombus(subject.p, subject.senses.smell, subject.level.size),
            *borders_from_radius(subject.p, subject.senses.smell, subject.level.size),
        ),
    ))

    if not is_railed:
        subject.act = act

